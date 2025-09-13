extends StatusEffect
class_name ElementalEffect

@export var damage_per_tick: float = 5.0

func _init(interval := 1.0, damage := 5.0):
	tick_interval = interval  # 每秒触发一次
	damage_per_tick = damage
