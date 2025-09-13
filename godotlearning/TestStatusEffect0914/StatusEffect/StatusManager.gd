extends Node

class_name StatusManager

@export var active_effects: Dictionary = {} # key: StatusEffect, value: {time_left, stacks}

func add_status(effect: StatusEffect, stacks: int = 1) -> void:
	if effect in active_effects:
		var data = active_effects[effect]
		data.stacks = min(data.stacks + stacks, effect.max_stacks)
		data.time_left = effect.duration
	else:
		active_effects[effect] = { "time_left": effect.duration, "stacks": stacks }
		effect.apply(get_parent(), stacks) #GPT这里是通过层数来确定 叠加伤害


func _process(delta: float) -> void: #再一个数组中管理 
	var to_remove: Array = []
	for effect in active_effects.keys():
		var data = active_effects[effect]
		effect.tick(get_parent(), delta, data.stacks)
		data.time_left -= delta 
		
		if data.time_left <= 0:
			to_remove.append(effect)
			
	for e in to_remove:
		e.remove(get_parent())
		active_effects.erase(e)
