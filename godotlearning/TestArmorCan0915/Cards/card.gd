extends Control
class_name Card

#主界面核心功能 ： 1.添加进入卡组 2.充能 3.充能完成
#弹仓UI核心功能 ： 1.鼠标悬停 显示信息 

# ===============================
# 信号定义
# ===============================
#卡片悬停 
signal hovered(card: Node) #传递给card manager 调整悬停时的卡组位置 
signal unhovered(card: Node)

#卡片buff
signal add_progress(pro : float) #进度调整加
signal card_buff_activated() #FIXME 这个信号的起名太迷惑了 应该改成系统性的

#CardMissionStart 
#CardMissionComplete

signal reduce_progress(pro : float) #进度条减少
signal card_buff_finished() 


signal card_removed()

# ===============================
# 导出变量
# ===============================
@export var data : BulletData
@export_enum("Recharge", "ColdDown")  var card_progress_type := "Recharge"

# ===============================
# 节点引用
# ===============================
@onready var offset: Control = $Offset #卡片本体
@onready var card_progress: CardProgress = $Offset/TextureRect/CardProgress #卡片进度条
@onready var animated_sprite_2d: AnimatedSprite2D = $Offset/AnimatedSprite2D #闪白部分 

@onready var info: MarginContainer = $Info #子弹信息 
@onready var bullet_name: Label = $Info/PanelContainer/HBoxContainer/BulletName
@onready var trigger_type: Label = $Info/PanelContainer/HBoxContainer/PanelContainer/TriggerType
@onready var description: Label = $Info/PanelContainer/HBoxContainer/Description

# ===============================
# Tween 变量
# ===============================
var posx_tween : Tween
var scale_tween : Tween
var show_tween : Tween
var rotate_tween : Tween
var pop_tween : Tween




func _ready() -> void:
	match card_progress_type:
		"Recharge":
			add_progress.connect(card_progress.add_progress) #链接卡片进度信号 
			card_progress.buff_activated.connect(func() :
				CardServer.card_fully_charge.emit(self) #充能完成  #FIXME
				card_buff_activated.emit()) #链接卡片充能激活信号 
		"ColdDown":
			card_buff_activated.emit()
			card_progress.buff_finished.connect(func() :
				CardServer.card_buff_finished.emit(self)
				card_buff_finished.emit()) #链接卡片buff结束信号 
	
	card_progress.set_up_progress(card_progress_type) #设置progress
	
	if data:
		offset.modulate = data.color #颜色 #设定卡片的样式 
		bullet_name.text = data.BulletName
		trigger_type.text = data.TriggerType
		description.text = data.description
		
	into_arry()
 

#===入场和出场===
func into_arry():
	offset.position.y = -245.0
	offset.scale = Vector2.ONE * .8
	offset.modulate.a = 0.0
	
	show_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	show_tween.tween_property(offset, "position:y", 0.0, .3)
	show_tween.tween_property(offset, "scale", Vector2.ONE, .3)
	show_tween.tween_property(offset, "modulate:a", 1.0, .3)
	
	_play_rotation_bounce()


func outof_arry():
	if show_tween:
		show_tween.kill()
	
	var up_time := .3
	var show_time := .2
	var que_time := .3
	
	animated_sprite_2d.play("default")
	_play_rotation_bounce()
	z_index = 2
	
	show_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
	show_tween.tween_property(offset, "position:y", -25.0, up_time)
	
	show_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	show_tween.tween_property(offset, "position:y", -245.0, .3).set_delay(up_time + show_time)
	show_tween.tween_property(offset, "scale", Vector2.ONE *.8, .3).set_delay(up_time + show_time)
	show_tween.tween_property(offset, "modulate:a", 0.0, .3).set_delay(up_time + show_time)
	
	await show_tween.finished
	card_removed.emit()
	await get_tree().process_frame
	queue_free()


func do_scale(target, duration, up : bool = true):
	if scale_tween:
		scale_tween.kill()
	
	if up:
		z_index = 2
		pop_up()
		info.show()
	else :
		z_index = 0
		pop_up(0.0)
		info.hide()
	
	var scale_tween = create_tween()
	scale_tween.tween_property(offset, "scale", target, duration) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)


func pop_up(posy : float = -25.0):
	if pop_tween:
		pop_tween.kill()
	
	animated_sprite_2d.play("default")
	
	pop_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	pop_tween.tween_property(offset, "position:y", posy, .3)
	
	_play_rotation_bounce()


func move_to(target: Vector2, duration := 0.3) -> void:
	if posx_tween:
		posx_tween.kill()
	
	var posx_tween := create_tween()
	posx_tween.tween_property(self, "position", target, duration) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)


func rotate_to(target_angle: float, duration := 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation", target_angle, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


# ===============================
# 内部工具：随机旋转回弹 /鼠标悬停 /卡片充能
# ===============================
func _play_rotation_bounce() -> void:
	if rotate_tween:
		rotate_tween.kill()
	
	var degree = randf_range(-30.0, 30.0)
	rotate_tween = create_tween().set_parallel()
	rotate_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	rotate_tween.tween_property(offset, "rotation_degrees", degree, 0.1)
	rotate_tween.set_trans(Tween.TRANS_ELASTIC)
	rotate_tween.tween_property(offset, "rotation_degrees", 0.0, 0.5).set_delay(0.1)

#卡片信号 在CardServer中依据Card Manager的配置完成链接
func _on_hovered() -> void: #鼠标悬停 
	emit_signal("hovered", self)
	do_scale(Vector2(1.4, 1.4), 0.3, true)


func _on_unhovered() -> void:
	emit_signal("unhovered", self)
	do_scale(Vector2(1.0, 1.0), 0.3, false)


func _add_charge():
	add_progress.emit(data.charger_nb)
