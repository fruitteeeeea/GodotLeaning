extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/NormalBullet.tres")

@onready var weapon: Weapon = $Weapon

@onready var cards_manager: CardsManager = $CardsManager #管理bullet pool
@onready var cards_manager_2: CardsManager = $CardsManager2 #管理magazine

@export var test_bullet_pool : Array[BulletData]

@export var bullet_and_cards := {} #武器中BulletInstance以及Cards的对应关系。

var is_locked := true

func _ready() -> void:
	complete_bullet_pool()
	spwan_bullet_card()
	pass


func complete_bullet_pool() -> void: #完成并分配 武器子弹池 #只在最开始执行一次
	var arr = []
	for i in test_bullet_pool: #添加现有的特殊子弹 
		if i is BulletData:
			arr.append(i)
	
	while arr.size() < weapon.bullet_pool.max_capacity: #填充普通子弹
		var new_data  = NORMAL_BULLET.duplicate(true)
		arr.append(new_data)

	arr.shuffle()
	
	#===创建子弹数据数列===
	for i in arr: #添加子弹 
		weapon.bullet_pool.add_bullet(i)
	
	weapon.bullet_pool.restore_bullet_pool() #根据给予的数列生成子弹实例


func spwan_bullet_card() -> void:
	is_locked = true
	for i in weapon.bullet_pool.get_bullet_pool():
		var data = i.data
		cards_manager.operate_cards(data, 1)
		await get_tree().create_timer(.1).timeout

	is_locked = false


func reload() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	weapon.reload()
	cards_manager_2.reset_cards()
	
	for i in weapon.magazine.get_magazine():
		var data = i.data
		
		cards_manager_2.operate_cards(data, 1) #TODO 这个data要设置一下 
		await get_tree().create_timer(.1).timeout
		
	is_locked = false
	
func _on_reload_pressed() -> void:
	reload()


func fire() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	var bullet = weapon.fire() as BulletInstance 
	if !bullet:
		return
	var card = cards_manager_2.cards_posx_info.keys().pick_random()
	cards_manager_2.remove_cards(card)
	cards_manager_2.operate_cards(bullet.data)
	#weapon.reload()
	#cards_manager_2.reset_cards()
	#
	#for i in weapon.magazine.get_magazine():
		#var data = i.data
		#cards_manager_2.operate_cards(data, 1)
		#await get_tree().create_timer(.1).timeout
	
	is_locked = false


func _on_fire_pressed() -> void:
	fire()
