extends Resource
class_name Magazine

@export var bullets: Array[BulletData] = []
@export var capacity: int = 5

func reload(pool: BulletPool) -> void:
	bullets.clear()
	var weighted_list: Array = []

	for b in pool.bullets: # 用 pool_weight 作为唯一的抽取权重
		var weight = int(b.pool_weight * 10) # 放大倍数，避免小数影响
		for i in range(weight):
			weighted_list.append(b)
	
	for i in range(capacity):
		if weighted_list.is_empty():
			break 
		var chosen = weighted_list.pick_random()
		bullets.append(chosen)

		# 装填特效
		if chosen.reload_effect != "":
			_apply_reload_effect(chosen)

func _apply_reload_effect(bullet: BulletData): #执行装填效果 
	#match bullet.reload_effect:
		#"heal_player":
			#Player.instance.hp += 5
		#"buff_reload_speed":
			#Player.instance.apply_buff("reload_speed", 1.5, 3.0)
	pass
