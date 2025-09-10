extends Node

signal DisplayShop


func display_dia(path : String):
	change_player_control(false)
	Dialogic.start(path)
	get_viewport().set_input_as_handled()


func display_shop():
	DisplayShop.emit()
	change_player_control(false)


func change_player_control(state : bool = true):
	var player = get_tree().get_first_node_in_group("player") as Player
	player.can_control = state
