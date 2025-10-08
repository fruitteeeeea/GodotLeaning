extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/BulletData/NormalBullet.tres")

@onready var weapon: Weapon = $Weapon

@onready var bullet_pool: CardsManager = $BulletPool #管理bullet pool
@onready var buff_list: CardsManager = $BuffList #管理magazine

@onready var magazine: CardsManager = $Magazine
@onready var activated_buff: CardsManager = $ActivatedBuff

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
		var bull = i as BulletInstance
		CardServer.manager_add_cards(bullet_pool, i)
		#cards_manager.add_cards(i)
		#await get_tree().create_timer(.1).timeout

	is_locked = false


func _on_reload_pressed() -> void:
	weapon.reload()


func _on_fire_pressed() -> void:
	fire()


func _on_magazine_relaod(magazine : Magazine) -> void:
	CardServer.reset_card_manager(buff_list)
	var narmal = []
	var specials = []
	
	for b in magazine.get_magazine():
		narmal.append(b.data.BulletName)
		if b.data.modifiers.size() > 0:
			specials.append(b.data.BulletName)
			CardServer.manager_add_cards(buff_list, b) #现在只加载有效的卡片 
	
	$CurrentMagazineBullet.text = str(narmal)
	$CurrentMagazineSpecialBullet.text = str(specials)


func fire() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	var bull = weapon.fire() as BulletInstance 
	if !bull:
		is_locked = false
		return

	CardServer.manager_remove_card(buff_list, bull)
	
	is_locked = false

#给随机卡片升级
func _on_random_add_pressed() -> void:
	if !CardServer.cards_manager_info.has(buff_list): return
	var list = CardServer.cards_manager_info[buff_list]
	if !list.size() > 0: return
	var node = list.keys().pick_random()
	var card = CardServer.find_card(buff_list, node) as Card
	card.add_progress.emit(randf_range(.1, .3) * 10)
