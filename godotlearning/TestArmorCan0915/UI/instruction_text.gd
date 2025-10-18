extends Label
class_name InstructionText

var display_tween : Tween

func update_instruction_text(_text : String):
	if display_tween:
		display_tween.kill()
	
	visible_ratio = 0.0
	text = _text
	
	display_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	display_tween.tween_property(self, "visible_ratio", 1.0, .3)
