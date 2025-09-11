extends Carrier



func _physics_process(delta: float) -> void:
	return

func get_throw_dir() -> Vector2:
	var dir = (get_global_mouse_position() - global_position).normalized()
	return dir
