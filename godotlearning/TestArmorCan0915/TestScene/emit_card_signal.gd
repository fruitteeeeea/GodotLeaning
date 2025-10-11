extends Control

@onready var armor_can_test: Node2D = $".."

func _on_emit_reload_pressed() -> void:
	armor_can_test.reload()
	PlayerBehaviorServer.emit_signal("player_load")


func _on_emit_fire_pressed() -> void:
	armor_can_test.fire()
	PlayerBehaviorServer.emit_signal("player_fire")


func _on_emit_hit_pressed() -> void:
	PlayerBehaviorServer.emit_signal("player_hitt")


func _on_emit_kill_pressed() -> void:
	PlayerBehaviorServer.emit_signal("player_kill")
