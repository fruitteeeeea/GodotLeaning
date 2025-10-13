extends Node2D

@onready var bullet_pool: CardsManager = $BulletPool
@onready var picked_bullet: CardsManager = $PickedBullet

var picked_bullet_arr : Array[DataContainer]

func _ready() -> void:
	#弹仓更改的时候 重新生成弹仓卡片 
	PlayerWeaponServer.weapon_set_settedup.connect(spwan_bullet_card)
	spwan_bullet_card()





#region BulletPool
func spwan_bullet_card() -> void:
	CardServer.reset_card_manager(bullet_pool)
	
	for i in PlayerWeaponServer.get_bullet_pool():
		var bull = i as DataContainer
		CardServer.manager_add_cards(bullet_pool, i) #弹仓卡片
#endregion 


#region PickedBullet
func spawn_picked_bullet() -> void:
	picked_bullet_arr.clear()
	CardServer.reset_card_manager(picked_bullet)
	picked_bullet_arr = PlayerWeaponServer.bullet_pool_pick_random_bullet(5)
	for i in picked_bullet_arr:
		CardServer.manager_add_cards(picked_bullet, i)

#endregion


func _on_pick_bullet_pressed() -> void:
	spawn_picked_bullet()
