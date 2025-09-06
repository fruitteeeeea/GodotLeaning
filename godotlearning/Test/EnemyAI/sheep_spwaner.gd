extends Node2D

@export var x_range := 800.0 * .8
@export var y_range := 448.0 * .8

@export var max_sheep := 12
@export var Sheep : PackedScene

func _on_timer_timeout() -> void:
	var sheep_nb = get_tree().get_node_count_in_group("Sheep")
	if sheep_nb >= max_sheep:
		return
	
	var sheep = Sheep.instantiate() as CharacterBody2D
	get_parent().call_deferred("add_child", sheep)
	sheep.global_position = Vector2(randf_range(-x_range, x_range), randf_range(-y_range, y_range))
