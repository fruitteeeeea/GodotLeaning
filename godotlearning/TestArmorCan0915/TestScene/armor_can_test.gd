extends Node2D

const NORMAL_BULLET = preload("res://TestArmorCan0915/TestResource/BulletData/NormalBullet.tres")

#@onready var weapon: Weapon = $Weapon

@onready var bullet_pool: CardsManager = $BulletPool #管理bullet pool
@onready var buff_list: CardsManager = $BuffList #管理magazine
@onready var magazine: CardsManager = $Magazine
@onready var activated_buff: CardsManager = $ActivatedBuff

@onready var activated_bullet: Label = $ActivatedBullet

@export var test_bullet_pool : Array[BulletData]
@export var test_bullet_pool_capacity := 20.0
@export var test_magazine_capacity := 10.0

var is_locked := true

func _ready() -> void:
	#添加卡片 
	CardServer.add_card_buff.connect(_on_card_buff_activated)
	
	CardServer.card_buff_activated.connect(func (_card : Card): #buff文字
		activated_bullet.text = PlayerBuffManager.get_all_activated_buff())
	CardServer.card_buff_finished.connect(func (_card : Card):
		activated_bullet.text = PlayerBuffManager.get_all_activated_buff())
	
	complete_bullet_pool()
	spwan_bullet_card()


func complete_bullet_pool() -> void: #完成并分配 武器子弹池 #只在最开始执行一次
	#注意先设定武器容量
	PlayerWeaponServer.setup_weapon_capacity(test_bullet_pool_capacity, test_magazine_capacity)
	#再设定子弹集
	PlayerWeaponServer.buildup_bullet_set(test_bullet_pool) 


func spwan_bullet_card() -> void:
	is_locked = true
	for i in PlayerWeaponServer.get_bullet_pool():
		var bull = i as DataContainer
		CardServer.manager_add_cards(bullet_pool, i) #弹仓卡片

	is_locked = false


func fire():
	if is_locked:
		return
	
	is_locked = true
	
	var bull = PlayerWeaponServer.fire() as DataContainer 
	if !bull:
		reload()
		is_locked = false
		return

	CardServer.manager_remove_card(magazine, bull)

	if bull.data.modifiers.size() > 0: #如果是特殊子弹 则添加卡片
		CardServer.manager_add_cards(buff_list, bull) #待激活buff卡片

	is_locked = false


func reload():
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

func _on_card_buff_activated(_card : Card) -> void:
	var bull  = DataContainer.new()
	bull.data = _card.data
	CardServer.manager_add_cards(activated_buff, bull) #已激活buff卡片

#随机为卡片充能
func _on_timer_timeout() -> void: 
	
	fire()
	
	var rng = randf()
	if rng > 0.0 && rng < .25:
		PlayerBehaviorServer.emit_signal("player_fire")
	elif rng > .25 && rng < .5:
		PlayerBehaviorServer.emit_signal("player_kill")
	elif rng > .5 && rng < .75:
		PlayerBehaviorServer.emit_signal("player_hitt")
	elif rng > .75:
		PlayerBehaviorServer.emit_signal("player_load")


func _on_game_speed_value_changed(value: float) -> void:
	Engine.time_scale = value
	print(Engine.time_scale )
