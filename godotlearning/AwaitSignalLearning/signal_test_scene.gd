extends Control

const CONFIRM_BOX = preload("res://AwaitSignalLearning/confirm_box.tscn")

func _on_button_pressed() -> void:
	do_stuff()


func do_stuff() -> void:
	print("开始执行")
	var panel = CONFIRM_BOX.instantiate() as ConfirmedBox
	get_tree().current_scene.add_child(panel)
	var _state = await panel.press_confirme
	if _state == true:
		print("选择成功！")
	else :
		print("选择失败！")
