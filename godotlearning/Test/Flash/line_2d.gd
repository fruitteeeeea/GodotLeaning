extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		
		add_point(Vector2.ZERO)
		add_point(get_global_mouse_position())
		width = 00.0
		
		#for i in range(10):
			#add_point(Vector2(320, 320))
#
			#var randx = randf_range(0, 640)
			#var randy = randf_range(0, 640)
			#
			#add_point(Vector2(randx, randy))
			#width = 100.0
			#await get_tree().create_timer(.01).timeout

		await get_tree().create_timer(.2).timeout
		clear_points()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	width = lerpf(width, 100.0, .2)
	pass
