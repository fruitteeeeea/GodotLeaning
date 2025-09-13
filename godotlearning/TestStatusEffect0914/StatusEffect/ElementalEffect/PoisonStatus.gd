extends ElementalEffect
class_name PoisonStatus

func _on_tick(target, delta: float, stack_count: int) -> void:
	var damage = damage_per_tick * stack_count
	#target.take_damage(damage)
	print("%s 中毒🐍 造成 %s 点伤害" % [target.name, damage])


func apply(target, stack_count: int = 1) -> void:
	print("%s 中毒了!" % target.name)


func remove(target) -> void:
	print("%s 中毒治愈了" % target.name)
