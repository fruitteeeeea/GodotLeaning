extends Node2D

signal status_effect_applied(target : StatusManager, effect : StatusEffect)


func apply_effect(target : Node2D, effect : StatusEffect):
	var status_manager = target.get_node_or_null("StatusManager") as StatusManager
	if !status_manager:
		printerr("% 未找到异常状态管理器")
		return
	
	status_effect_applied.emit(status_manager, effect)
