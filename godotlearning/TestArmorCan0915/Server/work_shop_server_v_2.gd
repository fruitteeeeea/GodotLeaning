extends Control
#添加卡片 #删除卡片
#选择行动的时候 消耗点数
#选择一次卡片之后 所需点数阶梯式增长。

signal workshop_opened
signal workshop_closed

signal update_pick_bullet_set(arr : Array[BulletData])
signal update_pick_bullets(arr : Array[BulletData])

enum WorkShopPhase { NORMAL, ADD, REMOVE, }
var current_phase : WorkShopPhase = WorkShopPhase.NORMAL

#卡片管理器
@onready var picked_bullet_set: CardsManager = $CardsManager/PickedBulletSet
@onready var picked_magazine: CardsManager = $CardsManager/PickedMagazine

var current_pick_bullet_set : Array[BulletData]
var current_picked_bullets : Array[BulletData] #当前抽取的子弹（增加子弹/减少子弹）

func _ready() -> void:
	update_pick_bullet_set.connect(_on_picked_card_spwan.bind(picked_bullet_set, true))
	update_pick_bullets.connect(_on_picked_card_spwan.bind(picked_magazine))

	picked_magazine.card_being_clicked.connect(_on_card_clicked)


#region Interface 对外接口
func open_workshop() -> void:
	show()
	
	PlayerWeaponServer.weapon_locked = true
	_get_player_current_weaponset()
	update_pick_bullet_set.emit(current_pick_bullet_set)
	workshop_opened.emit()

func close_workshop() -> void:
	workshop_closed.emit()
	PlayerWeaponServer.restore_bullet_pool()
	PlayerWeaponServer.weapon_locked = false

	hide()

#endregion

#region IntelFunc 内部函数
#获取当前卡片。
func _get_player_current_weaponset() -> void: 
	current_pick_bullet_set = PlayerWeaponServer.get_bullet_set() #直接赋值，同步修改 


#添加卡片的时候使用。
func _get_player_current_level_modifier() -> void: 
	for i in range(5): #依据弹夹数量生成modifier
		var res = ResourceServer.get_current_level_modifier(1) as BulletData
		current_picked_bullets.append(res)
	
	update_pick_bullets.emit(current_picked_bullets) 

#移除卡片的时候使用。
func _get_player_current_magazine_bullets() -> void:
	var load_count = min(5, current_pick_bullet_set.size())
	var new_list = current_pick_bullet_set.duplicate()
	new_list.shuffle()
	for i in range(load_count):
		var bull = new_list.pop_back()
		current_picked_bullets.append(bull)
		
	update_pick_bullets.emit(current_picked_bullets)


func _on_card_clicked(card : Card) -> void:
	match current_phase:
		WorkShopPhase.ADD:
			current_pick_bullet_set.append(card.data) 
		WorkShopPhase.REMOVE:
			current_pick_bullet_set.erase(card.data)
	
	card.hide()
	update_pick_bullet_set.emit(current_pick_bullet_set) 


func _on_picked_card_spwan(arr : Array[BulletData], _manager : CardsManager, _sort := false) -> void:
	CardServer.reset_card_manager(_manager)
	
	if _sort : BulletSorter.sort_bullets02(arr, "type")
	
	for bd in arr:
		var bull = DataContainer.new()
		bull.data = bd
		CardServer.manager_add_cards(_manager, bull)

#按钮操作
func _updata_button_state() -> void:
	match current_phase:
		WorkShopPhase.NORMAL:
			$Control/HBoxContainer.show()
			$Control/Done.hide()
		_:
			$Control/HBoxContainer.hide()
			$Control/Done.show()


func _on_add_card_pressed() -> void:
	current_phase = WorkShopPhase.ADD
	_get_player_current_level_modifier()
	_updata_button_state()


func _on_remove_card_pressed() -> void:
	current_phase = WorkShopPhase.REMOVE
	_get_player_current_magazine_bullets()
	_updata_button_state()


func _on_done_pressed() -> void:
	current_picked_bullets.clear()
	update_pick_bullet_set.emit(current_pick_bullet_set) 
	update_pick_bullets.emit(current_picked_bullets) 
	
	current_phase = WorkShopPhase.NORMAL
	_updata_button_state()
	$CardsManager/BulletSetSize.text = str(current_pick_bullet_set.size())


func _on_exit_work_shop_pressed() -> void:
	close_workshop()

#endregion
