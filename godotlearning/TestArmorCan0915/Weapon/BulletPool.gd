extends Resource
class_name BulletPool

signal bullet_added(bullet : BulletData)
signal bullet_picked(bullet : BulletData)
signal bullet_remove(bullet : BulletData)

@export var bullets: Array[BulletData] = [] #当前弹仓的数据 （基准 
@export var max_capacity: int = 20 # 初始容量（1x1 子弹算1格，1x2 算2格）

var bullet_instances : Array[BulletInstance] = [] #运行时候的子弹 

#升级 缩小其中一枚子弹的体积 放大一枚子弹的体积 

func restore_bullet_pool():
	bullet_instances.clear()
	if !bullets.size() > 0:
		print("BulletPool未找到BulletData")
		return
	
	for i in bullets:
		var bi = BulletInstance.new()
		bi.data = i
		bullet_instances.append(bi)


func pick_random_bullet(_nb : int) -> Array: #注意 这里的子弹被挑选了 也不会消失 
	var bullet_picked_list := []
	var nb = min(_nb, bullets.size()) #返回最小值 
	
	bullets.shuffle() #打乱顺序
	
	for b in range(nb):
		if bullets.is_empty():
			break
		
		var bullet = bullets.pop_front()
		bullet_picked_list.append(bullet)
		bullet_picked.emit(bullet)
		bullet_remove.emit(bullet)
		print(bullets)
		printt("最后挑选的子弹是", bullet)
	
	
	#printt("最后挑选的子弹是", bullet_picked_list)
	return bullet_picked_list



#====工房操作====
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
		bullet_added.emit(bullets)


func remove_bullet(bullet: BulletData) -> void: #移除子弹 
	bullets.erase(bullet)
	bullet_remove.emit(bullet)
