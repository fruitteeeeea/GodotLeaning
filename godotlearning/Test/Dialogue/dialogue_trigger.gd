extends Node2D

@export var is_in_area := false

@onready var press_e: PanelContainer = $PressE

func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null or is_in_area == false:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		DialogueServer.display_dia("res://Test/Dialogue/test01.dtl")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		press_e.show()
		is_in_area = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		press_e.hide()
		is_in_area = false
