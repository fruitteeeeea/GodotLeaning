extends Resource
class_name BulletPool

signal bullet_added(bullet : BulletData)
signal bullet_remove(bullet : BulletData)

#可以返回当前子弹数组 bullet_instance

@export var bullets: Array[BulletData] = [] #当前弹仓的数据 （基准 
var bullet_instances : Array[BulletInstance] = [] #运行时候的子弹 
#资源文件总是会指向一块内存。使用BulletInstance 来存储运行时子弹数据 

@export var max_capacity: int = 20 # 初始容量（1x1 子弹算1格，1x2 算2格） #TODO 同时考虑体积和重量


#====武器操作====
func restore_bullet_pool():
	for i in bullet_instances:
		i.queue_free() #手动清理
	bullet_instances.clear()
	
	if !bullets.size() > 0:
		print("BulletPool未找到BulletData")
		return
	
	for i in bullets:
		var bi = BulletInstance.new()
		bi.data = i
		bullet_instances.append(bi)

#TODO 是否有更高的概率抽中
func pick_random_bullet(_nb : int) -> Array[BulletInstance]: #注意 这里的子弹被挑选了 也不会消失 
	var bullet_picked_list : Array[BulletInstance] = []
	var nb = min(_nb, bullets.size()) #返回最小值 

	bullet_instances.shuffle() #打乱顺序
	
	for b in range(nb):
		if bullet_instances.is_empty():
			break
		
		var bullet = bullet_instances.pop_front() #子弹一次只会被选中一遍
		bullet_picked_list.append(bullet)
	
	restore_bullet_pool() #恢复一下原样
	return bullet_picked_list #返回带有指定数量BulletInstance的数组 


func get_bullet_pool() -> Array[BulletInstance]:
	return bullet_instances

#====工房操作====
func get_total_size() -> int:
	var total = 0
	for b in bullets:
		total += b.pool_size.x * b.pool_size.y
	return total


func can_add_bullet(bullet: BulletData) -> bool: #检查是否可以添加子弹 
	return get_total_size() + bullet.pool_size.x * bullet.pool_size.y <= max_capacity


#升级 缩小其中一枚子弹的体积 放大一枚子弹的体积 
func add_bullet(bullet: BulletData) -> void: #添加子弹 
	if can_add_bullet(bullet):
		bullets.append(bullet)
		bullet_added.emit(bullet)


func remove_bullet(bullet: BulletData) -> void: #移除子弹 
	bullets.erase(bullet)
	bullet_remove.emit(bullet)
