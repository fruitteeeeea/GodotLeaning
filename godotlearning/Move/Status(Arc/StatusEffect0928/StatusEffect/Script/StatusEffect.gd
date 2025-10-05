extends Resource
class_name StatusEffect

@export var name: String
@export var duration: float = 5.0
@export var max_stacks: int = 5

@export var tick_interval: float = 0.0 # 0 表示每帧触发, >0 表示间隔触发
var _tick_timer: float = 0.0

@export var is_buff: bool = false  # true=增益 false=减益

# 当状态应用时调用
func apply(target, stack_count: int = 1) -> void:
	_tick_timer = 0.0
	pass

func tick(target, delta: float, stack_count: int) -> void:
	if tick_interval <= 0.0:
		_on_tick(target, delta, stack_count) # 每帧触发
	else:
		_tick_timer -= delta
		if _tick_timer <= 0.0:
			_tick_timer += tick_interval
			_on_tick(target, tick_interval, stack_count) # 每间隔触发一次

# 状态移除时
func remove(target) -> void:
	pass

# 子类必须实现这个方法
func _on_tick(target, delta: float, stack_count: int) -> void:
	_apply_damage(target, delta, stack_count)
	_apply_effect(target, delta, stack_count)

#应用伤害的
func _apply_damage(target, delta: float, stack_count: int) -> void:
	pass 

#应用效果的
func _apply_effect(target, delta: float, stack_count: int) -> void:
	pass
