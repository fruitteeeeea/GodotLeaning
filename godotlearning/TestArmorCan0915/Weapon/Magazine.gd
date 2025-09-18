extends Resource
class_name Magazine

signal bullet_loaded(bullet : BulletData) #子弹被装载进入弹夹的时候发出 

@export var bullets: Array[BulletData] = []
@export var capacity: int = 5

func reload(pool: BulletPool) -> void:
	bullets.clear()
	
	#var weighted_list: Array = []
#
	#for b in pool.bullets: # 用 pool_weight 作为唯一的抽取权重
		#var weight = int(b.pool_weight * 10) # 放大倍数，避免小数影响
		#for i in range(weight):
			#weighted_list.append(b) 
	
	var bullet_list = pool.pick_random_bullet(capacity)
	for b in bullet_list:
		bullets.append(b)
		bullet_loaded.emit(b)
		
	#for i in range(capacity):
		#if weighted_list.is_empty():
			#break 
		#var chosen = weighted_list.pick_random()
		#bullets.append(chosen)

		# 装填特效
		#if chosen.reload_effect != "":
			#_apply_reload_effect(chosen)

func _apply_reload_effect(bullet: BulletData): #执行装填效果 
	match bullet.reload_effect:
		"heal_player":
			#Player.instance.hp += 5
			print("触发弹药装填效果 ： 治疗玩家生命")
		"buff_reload_speed":
			#Player.instance.apply_buff("reload_speed", 1.5, 3.0)
			print("触发弹药装填效果 ： 换弹速度提升")
	pass
