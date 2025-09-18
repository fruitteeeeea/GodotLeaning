extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/NormalBullet.tres")
const TEST_BULLET = preload("res://TestArmorCan0915/TestScene/test_bullet.tscn")

@export var special_bullet_array : Array[BulletData] = []

@onready var bullet_pool_spwaner: Marker2D = $Static/BulletPoolSpwaner
@onready var magazine_swpaner: Marker2D = $Static/MagazineSwpaner

@onready var weapon: Weapon = $Weapon

@export var test_bullet_pool := [] #存储实例化的测试子弹节点 
@export var test_bullet_dict : Dictionary = {}

#@export var magazine := []
#
#@export var pool_size := 20
#@export var magazine_size := 5

var is_locked := false

func _ready() -> void:
	complete_bullet_pool() #完成子弹池子 
	spwan_test_bullet()
	built_connection()
	
	#rebuilt_bullet_pool()


func complete_bullet_pool() -> void: #完成并分配 武器子弹池
	var arr = []
	for i in special_bullet_array: #添加现有的特殊子弹 
		if i is BulletData:
			arr.append(i)
	
	while arr.size() < weapon.bullet_pool.max_capacity: #填充普通子弹
		var new_data  = NORMAL_BULLET.duplicate(true)
		arr.append(new_data)

	arr.shuffle()
	
	var current_index = 0 #为子弹添加序号
	for i in arr:
		i.pool_index = current_index
		print("成功添加序号 ", current_index)
		current_index += 1
		
	
	#===创建子弹数据数列===
	
	
	for i in arr: #添加子弹 
		weapon.bullet_pool.add_bullet(i)
	
	for i in weapon.bullet_pool.bullets:
		print(i.description)


func spwan_test_bullet():
	if is_locked:
		return
	
	is_locked = true
	
	remove_bullet() #清除当前子弹 
	var pool_size = weapon.bullet_pool.bullets.size()
	var current_index = 0

	for i in pool_size: #为每一个bullet_data实例化子弹 
		var info = weapon.bullet_pool.bullets[current_index]
		add_bullet(info)
		current_index += 1
		
		await get_tree().create_timer(.01).timeout

	is_locked = false


func built_connection():
	weapon.magazine.bullet_loaded.connect(_on_bullet_reloaded)


func _on_bullet_reloaded(bullet : BulletData):
	var bullet_scene = test_bullet_dict[bullet.pool_index] as TestBullet#对应的测试子弹场景 
	bullet_scene.hide()
	print("隐藏一个子弹", bullet)
	#bullet_scene.queue_free()


#func rebuilt_bullet_pool():
	#if is_locked:
		#return
	#
	#is_locked = true
	#remove_bullet()
	#for i in range(pool_size):
		#add_bullet()
		#await get_tree().create_timer(.1).timeout
	#
	#is_locked = falsea





#func built_random_bullet_info() -> BulletData:
	#var bullet = BulletData.new()
	#
	#bullet.color = bullet.color_list[randi_range(0, 2)]
	#var sizex = randi_range(1, 2)
	#var sizey = randi_range(1, 3)
	#
	#bullet.pool_size = Vector2(sizex, sizey)
	#
	#print(bullet.color)
	#return bullet


func add_bullet(info : BulletData):
	#var info = built_random_bullet_info()
	
	var bullet = TEST_BULLET.instantiate()
	
	bullet.bullet_info = info
	
	bullet.global_position = Vector2.ONE * randf() * 5
	add_child(bullet)
	
	var index = info.pool_index
	test_bullet_dict[index]  = bullet #在字典中 确立对应的子弹 
	
	test_bullet_pool.append(bullet)


func remove_bullet():
	for i in test_bullet_pool:
		i.queue_free()
	#
	#for i in magazine:
		#i.queue_free()
	#
	test_bullet_pool.clear()
	#magazine.clear()


func reload():
	if is_locked:
		return
	
	weapon.magazine.reload(weapon.bullet_pool)
	print(weapon.magazine.bullets)

	#if is_locked or bullet_pool.size() < magazine_size:
		#return
	#
	#is_locked = true
	#for i in range(magazine_size):
		#
		#var bullet = bullet_pool.pick_random()
		#
		#bullet_pool.erase(bullet)
		#magazine.append(bullet)
		#
		#bullet.modulate.a *= .5
		#
		#await get_tree().create_timer(.1).timeout
		#
	#
	#is_locked = false
#
#
#func fire():
	#if is_locked or magazine.size() <= 0:
		#return
	#
	#is_locked = true
	#var bullet = magazine.pick_random()
	#magazine.erase(bullet)
	#bullet.queue_free()
		#
	#is_locked = false
	#pass
