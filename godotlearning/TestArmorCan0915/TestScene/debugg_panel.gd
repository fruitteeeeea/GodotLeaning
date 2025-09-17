extends Control

@onready var test_scene: Node2D = $"../.."


func _on_bulilt_bullet_pool_pressed() -> void:
	test_scene.rebuilt_bullet_pool()
	


func _on_reload_pressed() -> void:
	test_scene.reload()


func _on_fire_pressed() -> void:
	test_scene.fire()
