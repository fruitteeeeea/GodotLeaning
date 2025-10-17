extends Control
class_name BasicUIScene

signal pre_button_press
signal nex_button_press 

@onready var label: Label = $NinePatchRect/Label

@onready var pre: Button = $HBoxContainer/Pre
@onready var nex: Button = $HBoxContainer/Nex

var display_tween : Tween

func _ready() -> void:
	_inital_state()
	into_scene()

#region SetupText
#_type : 1是第首位 只有nex。 2是中间 有pre和nex。 3是末尾 只有pre
func set_up_panel(_text : String, _type : int) -> void:
	label.text = _text
	match _type:
		1:
			pre.disabled = true
			
		2:
			pass
		3:
			nex.disabled = true
		_:
			print("未找到该类型")
#endregion

#region DisplayTween

func _inital_state() -> void:
	modulate.a = 0.0
	position.y = -64.0


func into_scene() -> void:
	do_display_tween(1.0, 0.0)

func outof_scene() -> void:
	do_display_tween(0.0, 64.0, true)


func do_display_tween(_target_modulate_a : float, _target_posy : float, out := false) -> void:
	if display_tween:
		display_tween.kill()
	
	display_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	display_tween.tween_property(self, "modulate:a", _target_modulate_a, .3)
	display_tween.tween_property(self, "position:y", _target_posy, .3)
	await display_tween.finished
	if out: queue_free()
#endregion

#region ButtonPress
func _on_pre_pressed() -> void:
	pre_button_press.emit()


func _on_nex_pressed() -> void:
	nex_button_press.emit()
#endregion
