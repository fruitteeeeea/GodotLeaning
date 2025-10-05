extends NinePatchRect
class_name CardProgress

signal full_charge

var scale_tween : Tween

var next_sizex := .0 #这里需要注意一下 位置是旋转过后的 

var max_sizex :float
var fully_charged := false

@onready var control: Control = $Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_sizex = size.x
	next_sizex = -max_sizex
	
	control.position.x = next_sizex #注意是posx 然后在最底端


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		add_progress(.1)
	if event.is_action_pressed("mouse_right"):
		add_progress(-.1)

#输入需要增加的百分比 
func add_progress(pre : float) -> void:
	var final_add_scalex = max_sizex * pre
	do_scale_tween(final_add_scalex)


func do_scale_tween(v := 32.0):
	if fully_charged: return
	
	if scale_tween:
		scale_tween.kill()
	
	next_sizex += v
	next_sizex = clamp(next_sizex, min(next_sizex, max_sizex), 0) 

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	scale_tween.tween_property(control, "position:x", next_sizex, .5)
	
	if next_sizex >= 0.0: #注意 0.0才是最大值
		fully_charged = true
		full_charge.emit()
