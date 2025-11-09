extends Marker2D

@export var radius: float = 256.0

func _ready() -> void:
	add_to_group("lights")

func get_radius() -> float:
	return radius
