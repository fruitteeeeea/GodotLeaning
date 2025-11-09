extends ColorRect
class_name lighting

func _ready() -> void:
	show()


func _process(delta: float) -> void:
	var light_position = _get_light_position()

	material.set_shader_parameter("number_of_lights", light_position.size())
	material.set_shader_parameter("lights", light_position)


func _get_light_position():
	return get_tree().get_nodes_in_group("lights").map(
		func(light : Node2D):
			return light.get_global_transform_with_canvas().origin
	)
