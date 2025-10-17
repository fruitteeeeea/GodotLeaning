extends MarginContainer
class_name ConfirmationPanel

signal confirmed
signal canceled

@onready var info_1: Label = $PanelContainer/VBoxContainer/Info/Info1
@onready var info_2: Label = $PanelContainer/VBoxContainer/Info/Info2

#设置确认框文字
func setup(info01 : String, info02 : String) -> void:
	get_viewport().set_input_as_handled()
	info_1.text = info01
	info_2.text = info02


func _on_confirm_pressed() -> void:
	confirmed.emit()
	print("确认")
	queue_free()


func _on_cancel_pressed() -> void:
	canceled.emit()
	print("取消")
	queue_free()
