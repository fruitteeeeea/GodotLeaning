extends Resource
class_name BulletPool

@export var bullets: Array[BulletData] = []
@export var max_capacity: int = 20 # 初始容量（1x1 子弹算1格，1x2 算2格）

func get_total_size() -> int:
	var total = 0
	for b in bullets:
		total += b.pool_size.x * b.pool_size.y
	return total


func can_add_bullet(bullet: BulletData) -> bool: #检查是否可以添加子弹 
	return get_total_size() + bullet.pool_size.x * bullet.pool_size.y <= max_capacity


func add_bullet(bullet: BulletData) -> void: #添加子弹 
	if can_add_bullet(bullet):
		bullets.append(bullet)


func remove_bullet(bullet: BulletData) -> void: #移除子弹 
	bullets.erase(bullet)
