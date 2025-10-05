extends NinePatchRect

var scale_tween : Tween

var next_sizex := .0 #这里需要注意一下 位置是旋转过后的 

var max_sizex :float
var max_lightx : float

@onready var control: Control = $Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_sizex = size.x
	next_sizex = -max_sizex
	
	control.position.x = next_sizex


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		do_scale_tween()
	if event.is_action_pressed("mouse_right"):
		do_scale_tween(-32.0)

func do_scale_tween(v := 32.0):
	if scale_tween:
		scale_tween.kill()
	
	next_sizex += v
	next_sizex = clamp(next_sizex, min(next_sizex, max_sizex), 0) 

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	scale_tween.tween_property(control, "position:x", next_sizex, .5)
