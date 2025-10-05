extends Control
class_name Card

signal hovered(card: Node)
signal unhovered(card: Node)

@export var card_color : Color
@onready var animated_sprite_2d: AnimatedSprite2D = $Offset/AnimatedSprite2D

@export var data : BulletData
@onready var bullet_name: Label = $Info/PanelContainer/HBoxContainer/BulletName
@onready var trigger_type: Label = $Info/PanelContainer/HBoxContainer/PanelContainer/TriggerType
@onready var description: Label = $Info/PanelContainer/HBoxContainer/Description


var posx_tween : Tween
var scale_tween : Tween
var rotate_tween : Tween
var pop_tween : Tween

var show_tween : Tween

@onready var offset: Control = $Offset
@onready var info: MarginContainer = $Info

func _ready() -> void:
	if data:
		offset.modulate = data.color #颜色 
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
	
	if rotate_tween:
		rotate_tween.kill()
	
	var degree = randf_range(-30.0, 30.0)
	rotate_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	rotate_tween.tween_property(self, "rotation_degrees", degree, .1)
	rotate_tween.set_trans(Tween.TRANS_ELASTIC)
	rotate_tween.tween_property(self, "rotation_degrees", 0, .5).set_delay(.1)


func outof_arry():
	if show_tween:
		show_tween.kill()
	
	show_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	show_tween.tween_property(offset, "position:y", -245.0, .3)
	show_tween.tween_property(offset, "scale", Vector2.ONE *.8, .3)
	show_tween.tween_property(offset, "modulate:a", 0.0, .3)
	
	await show_tween.finished
	queue_free()


func move_to(target: Vector2, duration := 0.3) -> void:
	if posx_tween:
		posx_tween.kill()
	
	var posx_tween := create_tween()
	posx_tween.tween_property(self, "position", target, duration) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)


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
	
	var scale_tween := create_tween()
	scale_tween.tween_property(offset, "scale", target, duration) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
		
	if rotate_tween:
		rotate_tween.kill()
	
	var degree = randf_range(-30.0, 30.0)
	rotate_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	rotate_tween.tween_property(offset, "rotation_degrees", degree, .1)
	rotate_tween.set_trans(Tween.TRANS_ELASTIC)
	rotate_tween.tween_property(offset, "rotation_degrees", 0, .5).set_delay(.1)

func pop_up(posy : float = -25.0):
	if pop_tween:
		pop_tween.kill()
	
	animated_sprite_2d.play("default")
	
	pop_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	pop_tween.tween_property(offset, "position:y", posy, .3)


func rotate_to(target_angle: float, duration := 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation", target_angle, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
