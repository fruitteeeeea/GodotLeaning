extends Control

@onready var test_scene: Node2D = $"../.."
@onready var weapon: Weapon = $"../../Weapon"

@onready var bullet_pool: Label = $"../PanelContainer/VBoxContainer/BulletPool"
@onready var magazine: Label = $"../PanelContainer/VBoxContainer/Magazine"



func _physics_process(delta: float) -> void:
	bullet_pool.text = str(weapon.bullet_pool.bullets)
	magazine.text = str(weapon.magazine.bullets)

func _on_bulilt_bullet_pool_pressed() -> void:
	test_scene.rebuilt_bullet_pool()
	


func _on_reload_pressed() -> void:
	test_scene.reload()


func _on_fire_pressed() -> void:
	test_scene.fire()
