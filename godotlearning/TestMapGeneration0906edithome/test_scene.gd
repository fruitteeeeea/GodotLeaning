extends Node2D

@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator

var move := false

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		move = true
	if event.is_action_released("ui_accept"):
		move = false


func _physics_process(delta: float) -> void:
	if move:
		dungeon_generator.global_position = get_global_mouse_position()
