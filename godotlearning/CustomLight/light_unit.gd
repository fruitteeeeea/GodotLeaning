extends Node2D

@export var light_radius: float = 256.0
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	light_radius += (cos(time * 5) * 1) * delta * 15 # Sine movement

func _ready() -> void:
	add_to_group("lights")

func get_radius() -> float:
	return light_radius
