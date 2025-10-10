extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/BulletData/NormalBullet.tres")

#@onready var weapon: Weapon = $Weapon

@onready var bullet_pool: CardsManager = $BulletPool #管理bullet pool
@onready var buff_list: CardsManager = $BuffList #管理magazine
@onready var magazine: CardsManager = $Magazine
@onready var activated_buff: CardsManager = $ActivatedBuff

@export var test_bullet_pool : Array[BulletData]
@export var test_bullet_pool_capacity := 20.0
@export var test_magazine_capacity := 10.0

var is_locked := true

func _ready() -> void:
	Engine.time_scale *= 1000.0
	CardServer.card_fully_charge.connect(_on_card_fully_charge)
	
	complete_bullet_pool()
	spwan_bullet_card()


func complete_bullet_pool() -> void: #完成并分配 武器子弹池 #只在最开始执行一次
	#注意先设定武器容量
	PlayerWeaponServer.setup_weapon_capacity(test_bullet_pool_capacity, test_magazine_capacity)
	
	var arr = []
	for i in test_bullet_pool: #添加现有的特殊子弹 
		if i is BulletData:
			arr.append(i)
	
	while arr.size() < PlayerWeaponServer.bullet_pool_max_capacity: #填充普通子弹
		var new_data  = NORMAL_BULLET.duplicate(true)
		arr.append(new_data)

	arr.shuffle()
	
	#===创建子弹数据数列===
	for i in arr: #添加子弹 
		PlayerWeaponServer.add_bullet(i)
	 
	PlayerWeaponServer.restore_bullet_pool() #根据给予的数列生成子弹实例


func spwan_bullet_card() -> void:
	is_locked = true
	for i in PlayerWeaponServer.get_bullet_pool():
		var bull = i as DataContainer
		CardServer.manager_add_cards(bullet_pool, i) #弹仓卡片

	is_locked = false


func _on_reload_pressed() -> void:
	#var _magazine =  weapon.magazine
	#weapon.reload()
	PlayerWeaponServer.reload()
	
	CardServer.reset_card_manager(magazine)
	
	var narmal = []
	var specials = []
	
	#for b in _magazine.get_magazine():
	for b in PlayerWeaponServer.get_magazine():
		narmal.append(b.data.BulletName)
		CardServer.manager_add_cards(magazine, b) #弹夹卡片
		if b.data.modifiers.size() > 0:
			specials.append(b.data.BulletName)
	
	$CurrentMagazineBullet.text = str(narmal)
	$CurrentMagazineSpecialBullet.text = str(specials)

func _on_fire_pressed() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	var bull = PlayerWeaponServer.fire() as DataContainer 
	if !bull:
		_on_reload_pressed()
		is_locked = false
		return

	CardServer.manager_remove_card(magazine, bull)

	if bull.data.modifiers.size() > 0: #如果是特殊子弹 则添加卡片
		CardServer.manager_add_cards(buff_list, bull) #待激活buff卡片

	is_locked = false


func _on_card_fully_charge(_card : Card) -> void:
	var bull = DataContainer.new()
	bull.data = _card.data
	CardServer.manager_add_cards(activated_buff, bull) #已激活buff卡片


#随机为卡片充能
func _on_timer_timeout() -> void: 
	
	_on_fire_pressed()
	
	var rng = randf()
	if rng > 0.0 && rng < .25:
		PlayerBehaviorServer.emit_signal("player_fire")
	elif rng > .25 && rng < .5:
		PlayerBehaviorServer.emit_signal("player_kill")
	elif rng > .5 && rng < .75:
		PlayerBehaviorServer.emit_signal("player_hitt")
	elif rng > .75:
		PlayerBehaviorServer.emit_signal("player_load")
