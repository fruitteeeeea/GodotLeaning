extends Node2D

@onready var status_manager: StatusManager = $StatusManager

func _on_button_pressed() -> void:
	add_burn_status_effect()
	pass # Replace with function body.


func add_burn_status_effect():
	var burn = BurnStatus.new()
	status_manager.add_status(burn, 1)


func _on_button_2_pressed() -> void:
	var poison = PoisonStatus.new()
	status_manager.add_status(poison, .1)
