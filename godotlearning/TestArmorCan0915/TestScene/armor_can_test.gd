extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/BulletData/NormalBullet.tres")

@onready var weapon: Weapon = $Weapon

@onready var cards_manager: CardsManager = $CardsManager #管理bullet pool
@onready var cards_manager_2: CardsManager = $CardsManager2 #管理magazine

@export var test_bullet_pool : Array[BulletData]

var is_locked := true

func _ready() -> void:
	
	connect_cards_managersignal()
	
	complete_bullet_pool()
	spwan_bullet_card()


func connect_cards_managersignal(): #将弹夹与卡片管理器结合在一起 
	weapon.on_magazine_reload.connect(_on_magazine_relaod)


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
		var data = i
		cards_manager.operate_cards(data, 1)
		#await get_tree().create_timer(.1).timeout

	is_locked = false


func _on_reload_pressed() -> void:
	weapon.reload()


func _on_fire_pressed() -> void:
	fire()


func _on_magazine_relaod(magazine : Magazine) -> void:
	cards_manager_2.reset_cards()
	for i in magazine.get_magazine():
		var data = i
		
		cards_manager_2.operate_cards(data, 1)


func fire() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	var bullet = weapon.fire() as BulletInstance 
	if !bullet:
		is_locked = false
		return

	cards_manager_2.operate_cards(bullet, -1) #移除指定的卡片 
	
	is_locked = false


func _on_random_add_pressed() -> void:
	#给随机卡片升级
	if !cards_manager_2.card_nodes.keys().size() > 0: return
	var card = cards_manager_2.card_nodes.keys().pick_random() as Card
	card.add_progress.emit(randf_range(.1, .3) * 2)
	pass
