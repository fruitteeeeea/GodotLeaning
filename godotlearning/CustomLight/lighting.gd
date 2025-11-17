extends ColorRect
class_name Lighting

func _process(_delta: float) -> void:
	var positions: Array[Vector2] = []
	var radii: Array[float] = []

	for light in get_tree().get_nodes_in_group("lights"):
		positions.append(light.get_global_transform_with_canvas().origin)
		var radi = 256.0
		if light.has_method("get_radius"):
			radi = light.get_radius()
		radii.append(radi)

	material.set_shader_parameter("number_of_lights", positions.size())
	material.set_shader_parameter("lights", positions)
	material.set_shader_parameter("light_radii", radii)
