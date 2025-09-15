extends Node2D

@onready var status_manager: StatusManager = $Dummy00/StatusManager

func _on_button_pressed() -> void:
	add_burn_status_effect()
	pass # Replace with function body.


func add_burn_status_effect():
	var burn = preload("res://TestStatusEffect0914/Resource/burn001.tres")
	status_manager.add_status(burn, 1)


func _on_button_2_pressed() -> void:
	var poison = preload("res://TestStatusEffect0914/Resource/pois001.tres")
	status_manager.add_status(poison, .1)


func _on_button_3_pressed() -> void:
	var roar = preload("res://TestStatusEffect0914/Resource/stun001.tres")
	status_manager.add_status(roar, .1)
