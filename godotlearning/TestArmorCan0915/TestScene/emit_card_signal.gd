extends Control

func _on_emit_reload_pressed() -> void:
	CardServer.emit_signal("add_load_progress")


func _on_emit_fire_pressed() -> void:
	CardServer.emit_signal("add_fire_progress")


func _on_emit_hit_pressed() -> void:
	CardServer.emit_signal("add_hitt_progress")


func _on_emit_kill_pressed() -> void:
	CardServer.emit_signal("add_kill_progress")
