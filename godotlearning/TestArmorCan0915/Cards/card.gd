extends Control
class_name Card

#主界面核心功能 ： 1.添加进入卡组 2.充能 3.充能完成
#弹仓UI核心功能 ： 1.鼠标悬停 显示信息 

# ===============================
# 信号定义
# ===============================
signal hovered(card: Node)
signal unhovered(card: Node)

signal add_progress(pro : float) #进度调整加
signal card_full_charged()
signal buff_activated(buff : Resource) #激活debuff

# ===============================
# 导出变量
# ===============================
@export var data : BulletData

#充能类型 
enum ChargeEvent { ON_RELOAD, ON_FIRE, ON_HIT, ON_KILL } #不同阶段触发的充能 
@export var charger: ChargeEvent = ChargeEvent.ON_FIRE #默认是开火充能
@export_range(0.0, 1.0, .05) var charger_nb := .3

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


func _add_charge():
	add_progress.emit(charger_nb)


func _ready() -> void:
	match charger: #根据自身的充能类型 链接卡片充能信号 
		ChargeEvent.ON_FIRE: 
			CardServer.add_fire_progress.connect(_add_charge)
	
	add_progress.connect(card_progress.add_progress) #链接卡片进度信号 
	card_progress.full_charge.connect(func() : card_full_charged.emit()) #链接卡片充能完成信号 
	
	if data:
		offset.modulate = data.color #颜色 #设定卡片的样式 
		bullet_name.text = data.BulletName
		trigger_type.text = data.TriggerType
		description.text = data.description
	
	mouse_entered.connect(func(): emit_signal("hovered", self))
	mouse_entered.connect(do_scale.bind(Vector2(1.4, 1.4), 0.3, true))
	
	mouse_exited.connect(func(): emit_signal("unhovered", self))
	mouse_exited.connect(do_scale.bind(Vector2(1.0, 1.0), 0.3, false))
	
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
	#show_tween.tween_property(offset, "scale:x", scale.x * -2, up_time)
	
	show_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	show_tween.tween_property(offset, "position:y", -245.0, .3).set_delay(up_time + show_time)
	show_tween.tween_property(offset, "scale", Vector2.ONE *.8, .3).set_delay(up_time + show_time)
	show_tween.tween_property(offset, "modulate:a", 0.0, .3).set_delay(up_time + show_time)
	
	await show_tween.finished
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
# 内部工具：随机旋转回弹
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
