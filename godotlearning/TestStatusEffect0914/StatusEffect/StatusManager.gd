extends Node
class_name StatusManager

signal status_added(effect : StatusEffect)
signal status_removed(effect : StatusEffect)

@export var active_effects: Dictionary = {} # key: StatusEffect, value: {time_left, stacks}

func _ready() -> void:
	StatusEffectServer.status_effect_applied.connect(_on_effect_added)  #通过全局节点添加 


func _on_effect_added(manager : StatusManager, effect :StatusEffect) -> void:
	if manager == self:
		add_status(effect)


func add_status(effect: StatusEffect, stacks: int = 1) -> void: #添加状态 
	status_added.emit(effect)
	
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
		
		if data.time_left <= 0: #管理异常状态的持续时间 
			to_remove.append(effect)
			
	for e in to_remove:
		status_removed.emit(e)
		e.remove(get_parent())
		active_effects.erase(e)
