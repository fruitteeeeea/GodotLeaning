extends Control

var display_tween : Tween
var show_pos := 0.0
var hide_pos := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pos = size.x
	position.x = hide_pos
	
	DialogueServer.DisplayShop.connect(do_display_tween.bind(true))


func _on_button_pressed() -> void:
	do_display_tween(false)
	DialogueServer.change_player_control()

func do_display_tween(show := true):
	
	var zoom = 1
	var cam = get_viewport().get_camera_2d()
	
	if display_tween:
		display_tween.kill()
	
	var pos : float
	
	if show:
		pos = show_pos
		zoom *= 1.5
	else :
		pos = hide_pos
		zoom /= 1.5
	
	display_tween =create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	display_tween.tween_property(self, "position:x", pos, .3)
	display_tween.tween_property(cam, "zoom", Vector2.ONE * zoom, .3)
	print(pos)
	
	pass


func _on_hidden() -> void:
	DialogueServer.change_player_control(true)
