extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(randf()*.5).timeout
	animation_player.play("Idle")
	animation_player.speed_scale *= randf_range(.8, 1.2) * .3
	
