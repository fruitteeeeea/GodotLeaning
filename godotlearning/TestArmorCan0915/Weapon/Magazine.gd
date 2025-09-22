extends Resource
class_name Magazine

signal on_bullet_loaded(bullet : BulletData) #子弹被装载进入弹夹的时候发出 
signal on_bullet_fired(bullet : BulletData)

var bullet_instances : Array[BulletInstance] = [] #存储运行时的子弹 

@export var capacity: int = 5

func reload(pool: BulletPool) -> void: #从子弹池子里获得bo 装填至bullet_instances
	bullet_instances.clear()

	var bullet_list : Array[BulletInstance] = pool.pick_random_bullet(capacity)
	
	for bi in bullet_list:
		bullet_instances.append(bi)
		on_bullet_loaded.emit(bi) #如果选中子弹有装填特效 需要触发装填特效 


func get_fire_nullet() -> BulletInstance: #获取需要发射的子弹 
	if bullet_instances.is_empty():
		printerr("弹夹是空的")
		return
	
	var bi = bullet_instances.pop_front() as BulletInstance
	on_bullet_fired.emit(bi.data) #如果选中子弹有发射特效 需要触发发射特效 
	return bi


func get_magazine() -> Array[BulletInstance]: #获取当前弹夹
	return bullet_instances
