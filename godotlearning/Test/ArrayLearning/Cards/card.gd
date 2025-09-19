extends Control
class_name Card

var posx_tween : Tween
var scale_tween : Tween
var rotate_tween : Tween
var pop_tween : Tween

@onready var offset: Control = $Offset

signal hovered(card: Node)
signal unhovered(card: Node)

func _ready() -> void:
	mouse_entered.connect(func(): emit_signal("hovered", self))
	mouse_entered.connect(do_scale.bind(Vector2(.9, .9), 0.3, true))
	
	mouse_exited.connect(func(): emit_signal("unhovered", self))
	mouse_exited.connect(do_scale.bind(Vector2(.5, .5), 0.3, false))


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
	else :
		z_index = 0
		pop_up(0.0)
	
	var scale_tween := create_tween()
	scale_tween.tween_property(self, "scale", target, duration) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
		
	if rotate_tween:
		rotate_tween.kill()
	
	var degree = randf_range(-30.0, 30.0)
	rotate_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	rotate_tween.tween_property(self, "rotation_degrees", degree, .1)
	rotate_tween.set_trans(Tween.TRANS_ELASTIC)
	rotate_tween.tween_property(self, "rotation_degrees", 0, .5).set_delay(.1)

func pop_up(posy : float = -20.0):
	if pop_tween:
		pop_tween.kill()
	
	pop_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	pop_tween.tween_property(offset, "position:y", posy, .3)


func rotate_to(target_angle: float, duration := 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation", target_angle, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
