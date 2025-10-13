extends Node2D

@onready var bullet_pool: CardsManager = $BulletPool #管理bullet pool
@onready var buff_list: CardsManager = $BuffList #管理magazine
@onready var magazine: CardsManager = $Magazine
@onready var activated_buff: CardsManager = $ActivatedBuff

@onready var activated_bullet: Label = $ActivatedBullet

@export var test_weaponset : PlayerWeaponSet

var is_locked := true

func _ready() -> void:
	#弹仓更改的时候 重新生成弹仓卡片 
	PlayerWeaponServer.weapon_set_settedup.connect(spwan_bullet_card)
	#完成并分配 武器子弹池 #只在最开始执行一次
	PlayerWeaponServer.setup_weapon_set(test_weaponset)

	#添加buff激活卡片 
	CardServer.add_card_buff.connect(_on_card_buff_activated)
	#buff文字
	CardServer.card_buff_activated.connect(func (_card : Card): 
		activated_bullet.text = PlayerBuffManager.get_all_activated_buff())
	CardServer.card_buff_finished.connect(func (_card : Card):
		activated_bullet.text = PlayerBuffManager.get_all_activated_buff())


func spwan_bullet_card() -> void:
	is_locked = true
	CardServer.reset_card_manager(bullet_pool)
	
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


func _on_save_weapon_set_pressed() -> void:
	PlayerWeaponServer.save_player_weapon_set()


func _on_print_weapon_set_pressed() -> void:
	PlayerWeaponServer.load_player_weapon_set()
