extends Control
class_name ConfirmedBox

signal press_confirme (state : bool)


func _on_button_pressed() -> void:
	press_confirme.emit(true)
	queue_free()


func _on_button_2_pressed() -> void:
	press_confirme.emit(false)
	queue_free()
