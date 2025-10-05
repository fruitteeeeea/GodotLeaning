extends StatusEffect
class_name ElementalEffect

@export_enum("Normal", "Fire", "Ice", "Poison") var elemental_type := "Normal"

@export_category("AttributeBase")
@export var damage_per_tick: float = 5.0


@export_category("BehaviorBase") #0是加入时候执行一次 1是每次生效都执行 2是结束的时候执行
@export var target_stun := [false, false, false] #目标是否眩晕 
@export var target_petrify := [false, false, false] #目标是否石化 
@export var target_fear := [false, false, false] #目标是否恐惧


@export_category("Visual")
@export var status_effect_icon : String = ""

@export_category("Debugg")
@export var debugg_string_apply := "效果添加" #TEST
@export var debugg_string_tick := "效果执行"
@export var debugg_string_remove := "效果移除"

func _init(interval := 1.0, damage := 5.0):
	tick_interval = interval  # 每秒触发一次
	damage_per_tick = damage


func apply(target, stack_count: int = 1) -> void: #添加的时候执行一次 
	excute_status_effect(target, 0)
	print("%s %s" % [target.name, debugg_string_apply])


func _apply_damage(target, delta: float, stack_count: int) -> void:
	var damage = damage_per_tick * stack_count
	#target.take_damage(damage)
	print("%s %s 造成 %s 点伤害" % [target.name, debugg_string_tick, damage])


func remove(target) -> void:
	print("%s %s" % [target.name, debugg_string_remove])


func excute_status_effect(target : Node, index := 0): #查看是否要执行相应操作 
	if target_stun[index] == true:
		var AIC = target.get_node_or_null("VisibleOnScreenEnabler2D/AIControler") as AIControler
		if AIC:
			AIC.get_stun()
