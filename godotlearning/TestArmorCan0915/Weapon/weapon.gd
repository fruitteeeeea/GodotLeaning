extends Node2D
class_name Weapon

#发射子弹 #effect_list #bullet_list

signal on_bullet_hit(bullet : BulletData)
signal on_bullet_kill(bullet : BulletData)

@export var bullet_pool: BulletPool
@export var magazine: Magazine

var bullet_list := [] #维持的子弹
var effect_list := [] #维持的效果 

func _ready() -> void:
	magazine.on_bullet_loaded.connect(trigger_effect.bind("ON_RELOAD"))
	magazine.on_bullet_fired.connect(trigger_effect.bind("ON_FIRE"))


func trigger_effect(effect : String, bullet: BulletData):
	match effect:
		"ON_RELOAD":
			_apply_effect(bullet, "ON_RELOAD")
			print("触发了装填特效")
		"ON_FIRE":
			print("触发了开火特效")
		"ON_HIT":
			print("触发了击中特效")
		"ON_KILL":
			print("触发了击杀特效")
		_:
			print("未找到特效", effect)


func reload():
	magazine.reload(bullet_pool)


func fire(): #返回一个发射子弹的类型 
	if magazine.bullets.is_empty():
		reload()
		return

	#TODO 随机选中弹夹中的子弹 
	var bullet = magazine.get_fire_nullet() #发射子弹函数 发射弹夹最前面的子弹 
	#var bullet_scene = preload("res://Bullet.tscn").instantiate()
	#bullet_scene.data = bullet
	#get_tree().current_scene.add_child(bullet_scene)


#特殊效果 
func _apply_effect(bullet: BulletData, Type : String = "ON_RELOAD"): #执行装填效果 
	match bullet.reload_effect:
		"heal_player":
			#Player.instance.hp += 5
			print("触发弹药装填效果 ： 治疗玩家生命")
		"buff_reload_speed":
			#Player.instance.apply_buff("reload_speed", 1.5, 3.0)
			print("触发弹药装填效果 ： 换弹速度提升")
