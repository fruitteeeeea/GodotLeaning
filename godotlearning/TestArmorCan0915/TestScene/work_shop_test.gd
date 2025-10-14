extends Node2D

@onready var picked_bullet_set: CardsManager = $PickedBulletSet
@onready var picked_magazine: CardsManager = $PickedMagazine

var picked_bullet_arr : Array[DataContainer]

func _ready() -> void:
	#弹仓更改的时候 重新生成弹仓卡片 
	WorkShopServer.update_pick_bullet_set.connect(_on_picked_card_spwan.bind(picked_bullet_set))
	WorkShopServer.update_pick_magazine.connect(_on_picked_card_spwan.bind(picked_magazine))
	
	WorkShopServer.is_modifiy_mod = true
	#获取一下当前的 武器配置 
	WorkShopServer.get_player_current_weaponset()

#根据bullet_set 指定 manager 生成卡片
func _on_picked_card_spwan(arr : Array[BulletData], _manager : CardsManager, ) -> void:
	CardServer.reset_card_manager(_manager)
	
	for bd in arr:
		var bull = DataContainer.new()
		bull.data = bd
		CardServer.manager_add_cards(_manager, bull)


#region PickedBulletSet
#endregion 


#region PickedMagazine
#endregion
