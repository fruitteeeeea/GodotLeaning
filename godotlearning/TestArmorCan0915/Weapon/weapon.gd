extends Node2D
class_name Weapon

#发射子弹 #effect_list #bullet_list

signal on_magazine_reload(magazine : Magazine)

signal on_bullet_hit(bullet : BulletInstance)
signal on_bullet_kill(bullet : BulletInstance)

@export var bullet_pool: BulletPool
@export var magazine: Magazine

var bullet_list := [] #维持的子弹
var effect_list := [] #维持的效果 

func _ready() -> void:
	magazine.on_bullet_loaded.connect(check_bullet_trigeer.bind(BulletModifierData.TriggerEvent.ON_RELOAD))
	magazine.on_bullet_fired.connect(check_bullet_trigeer.bind(BulletModifierData.TriggerEvent.ON_FIRE))

#装填
func reload():
	if magazine.reload(bullet_pool) == true:
		print("成功装填")
		on_magazine_reload.emit(magazine) #成功装填了

#开火
func fire() -> BulletInstance: #返回一个发射子弹的类型 
	if magazine.bullet_instances.is_empty():
		reload()
		return

	if magazine.is_reloading:
		print("reload")
		return

	#TODO 随机选中弹夹中的子弹 
	var bullet = magazine.get_fire_nullet() as BulletInstance#发射子弹函数 发射弹夹最前面的子弹 
	return bullet

#检查子弹是否拥有指定的 trigger 的Modifier
func check_bullet_trigeer(bullet_instance : BulletInstance, trigger_type : BulletModifierData.TriggerEvent) -> void: #如果有对应的效果 需要执行的 
	var modifiers = bullet_instance.data.get_modifiers(trigger_type)
	for m in modifiers:
		_apply_effect(m)

#在此处应用 BulletModifier 的 Effect
func _apply_effect(modifier: BulletModifierData): #执行装填效果 
	match modifier.effect:
		"heal_player":
			#Player.instance.hp += 5
			print("触发弹药装填效果 ： 治疗玩家生命") #TODO 这里区分一下 触发的效果 
		
		"criti_hit":
			print("触发弹药发射效果 ： 暴击几率增加")
		
		"buff_reload_speed":
			#Player.instance.apply_buff("reload_speed", 1.5, 3.0)
			print("触发弹药装填效果 ： 换弹速度提升")
		_:
			print("未找到效果 ： ", modifier.effect)
			return
