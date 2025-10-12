extends Node2D

signal bullet_added(bullet : BulletData) #子弹被添加
signal bullet_remove(bullet : BulletData)

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/BulletData/NormalBullet.tres")


#region BulletPool
#===BulletPool的功能===
var bullet_set : Array[BulletData] = [] #基准弹仓数据
var runtime_bullet_pool : Array[DataContainer] = [] #运行时的子弹实例

@export var bullet_pool_max_capacity: int = 20 #弹仓容量

func ____BulletPool____(): pass
#输入一个带有特殊BulletData的数组 
#补充普通BulletData
#按照弹仓容量完成BulletSet
func buildup_bullet_set(test_bullet_pool : Array[BulletData]) -> void: 
	var arr = []
	for i in test_bullet_pool: #添加现有的特殊子弹 
		arr.append(i)
	
	while arr.size() < get_bullet_pool_capacity(): #填充普通子弹
		var new_data  = NORMAL_BULLET.duplicate(true)
		arr.append(new_data)

	arr.shuffle()
	
	#===创建子弹数据数列===
	for i in arr: #添加子弹 
		add_bullet(i)
	 
	restore_bullet_pool() #根据给予的数列生成子弹实例



#重置子弹池子
func restore_bullet_pool():
	runtime_bullet_pool.clear() #使用Refcount 清除引用 自动销毁
	
	if !bullet_set.size() > 0:
		print("BulletPool未找到BulletData")
		return
	
	for i in bullet_set:
		var bull = DataContainer.new()
		bull.data = i
		runtime_bullet_pool.append(bull)


func bullet_pool_pick_random_bullet(_nb : int) -> Array[DataContainer]:
	var bullet_picked_list : Array[DataContainer] = []
	var nb = min(_nb, runtime_bullet_pool.size()) #返回最小值 

	runtime_bullet_pool.shuffle() #打乱顺序
	for b in range(nb):
		if runtime_bullet_pool.is_empty(): 
			break
		
		var bullet = runtime_bullet_pool.pop_front() #子弹一次只会被选中一遍
		bullet_picked_list.append(bullet)
	
	restore_bullet_pool() #恢复子弹池子
	return bullet_picked_list #返回带有指定数量DataContainer的数组 #
	


func get_bullet_pool() -> Array[DataContainer]:
	return runtime_bullet_pool


#==工房操作===
func get_total_size() -> int:
	var total = 0
	for b in bullet_set:
		total += b.pool_size.x * b.pool_size.y
	return total


func can_add_bullet(bullet: BulletData) -> bool: #检查是否可以添加子弹 
	return get_total_size() + bullet.pool_size.x * bullet.pool_size.y <= bullet_pool_max_capacity


#升级 缩小其中一枚子弹的体积 放大一枚子弹的体积 
func add_bullet(bullet: BulletData) -> void: #添加子弹 
	if can_add_bullet(bullet):
		bullet_set.append(bullet)
		bullet_added.emit(bullet)


func remove_bullet(bullet: BulletData) -> void: #移除子弹 
	bullet_set.erase(bullet)
	bullet_remove.emit(bullet)
#endregion

#region Magazine
#===Magazine的功能===
signal on_bullet_loaded(bullet : DataContainer) #子弹被装载进入弹夹的时候发出 
signal on_bullet_fired(bullet : DataContainer)

var runtime_magazine : Array[DataContainer] = [] #运行时的子弹实例
@export var magazine_max_capacity: int = 10.0 #弹夹容量

var is_reloading := false #是否处于装填状态

func ____Magazine____(): pass

func reload() -> bool: #从子弹池子里获得bo 装填至bullet_instances
	if is_reloading: return false #返回装填失败 

	is_reloading = true
	
	runtime_magazine.clear()

	var bullet_list : Array[DataContainer] = bullet_pool_pick_random_bullet(magazine_max_capacity)
	if bullet_list == []: return false #如果bullet_list是空的 返回装填失败
	
	for bull in bullet_list:
		runtime_magazine.append(bull) 
		on_bullet_loaded.emit(bull) #如果选中子弹有装填特效 需要触发装填特效 
		
	is_reloading = false
	
	PlayerBehaviorServer.player_load.emit() #发送玩家成功装填信号 
	return true #返回装填成功 


func get_fire_nullet() -> DataContainer: #获取需要发射的子弹 
	if is_reloading:
		printerr("弹夹装填中")
		return

	if runtime_magazine.is_empty():
		printerr("弹夹是空的")
		return

	var bull = runtime_magazine.pop_front() as DataContainer
	on_bullet_fired.emit(bull) #如果选中子弹有发射特效 需要触发发射特效 
	return bull


func get_magazine() -> Array[DataContainer]: #获取当前弹夹
	return runtime_magazine
#endregion

#region Weapon
#===Weapon的功能===
func ____Weapon____(): pass

func setup_weapon_capacity(pool_capa : int, magaz_capa : int) -> void:
	bullet_pool_max_capacity = pool_capa
	magazine_max_capacity = magaz_capa

#限制弹仓最大值
func get_bullet_pool_capacity() -> int:
	return min(bullet_pool_max_capacity, 25)

#限制弹夹最大值
func get_magazine_capacity() -> int:
	return min(magazine_max_capacity, 10)


func fire() -> DataContainer: #返回一个
	if runtime_magazine.is_empty():
		reload()
		return

	if is_reloading:
		print("reload")
		return

	var bullet = get_fire_nullet() as DataContainer#发射子弹函数 发射弹夹最前面的子弹 
	return bullet

#endregion
