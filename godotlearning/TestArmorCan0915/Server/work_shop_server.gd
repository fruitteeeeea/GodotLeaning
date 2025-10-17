extends Control
#用于修改玩家弹夹的通道 

signal workshop_opened
signal workshop_closed

signal update_pick_bullet_set(arr : Array[BulletData])
signal update_pick_magazine(arr : Array[BulletData])

#修改玩家弹夹步骤 

#工房修改玩家 WeaponSet 的顺序
#1. 锁定 WeaponS et
#2. 获取玩家当前 Weapon Set
#3. 对玩家当前 Weapon Set 进行修改 
#4. 设置玩家当前 Weapon Set
#5. 解锁 Weapon Set

#步骤
#1.显示玩家弹仓 显示可选择修改器 
#2.选择修改器 抽取可应用子弹
#3.选择需要应用的子弹
#4.确认应用子弹
#5.修改器选择页面


#工房获取 Modifier 的顺序 
#1. 获取当前可获取内容等级 

var is_modifiy_mod := false
var is_locked := false #进行危险操作的时候 可以先锁住

#===卡片管理器===
@onready var picked_bullet_set: CardsManager = $Cards/PickedBulletSet
@onready var picked_magazine: CardsManager = $Cards/PickedMagazine


#===Test相关===
@export var test_bullet_data01 : BulletData 
@export var test_bullet_data02 : BulletData 

@export var test_modifier : BulletModifierData

func _ready() -> void:
	update_pick_bullet_set.connect(_on_picked_card_spwan.bind(picked_bullet_set))
	update_pick_magazine.connect(_on_picked_card_spwan.bind(picked_magazine))
	
	#for i in bullet_modifier.get_children(): #绑定修改器选择按钮
		#if i is Button:
			#i.pressed.connect(_updata_selected_button.bind(i))

func open_workshop() -> void:
	is_modifiy_mod = true
	show()
	get_player_current_weaponset()
	workshop_opened.emit()


func close_workshop() -> void:
	is_modifiy_mod = false
	hide()
	workshop_closed.emit()


#====PHASE01====
#region WeaponSet

var current_pick_bullet_set : Array[BulletData] = [] #这里用一下set

var curretn_bullet_pool_capacity : int
var current_magazine_capacity : int

var current_pick_magazine : Array[BulletData] = []

#获取玩家当前的 武器配置 （子弹配置 弹仓容量 弹夹容量）
func get_player_current_weaponset() -> void:
	current_pick_bullet_set = PlayerWeaponServer.get_bullet_set()
	BulletSorter.sort_bullets02(current_pick_bullet_set, "type") #这里对数组进行一下整理。
	
	update_pick_bullet_set.emit(current_pick_bullet_set)
	
	curretn_bullet_pool_capacity = PlayerWeaponServer.get_bullet_pool_capacity()
	current_magazine_capacity = PlayerWeaponServer.get_magazine_capacity()

#endregion

#region WorkShop
@onready var bullet_modifier: GridContainer = $PanelContainer/BulletModifier

func apply_modifier_to_bullet():
	pass


func _updata_selected_button(i : Button) -> void:
	print(i.name)


#endregion



var current_selected_data : BulletData
var current_selected_modifier : BulletModifierData




#region WorkFlow

#region PHASE01
func _on_phase01_enter() -> void:
	_spawn_bullet_pool_cards()
	_spwan_modifier_cards()

#region SetUp
#生成弹仓卡片
func _spawn_bullet_pool_cards() -> void:
	pass

#生成修改器卡片
func _spwan_modifier_cards() -> void:
	pass

#endregion

#region Operation
#按下
func _on_fire_bullet_pressed() -> void:
	current_selected_data = test_bullet_data01
	repick_magazine()


func _on_ice_bullet_pressed() -> void:
	current_selected_data = test_bullet_data02
	repick_magazine()


func _on_modifier_selected(_data) -> void:
	current_selected_data = _data
	pass


#endregion

#endregion



#region PHASE02
#当modifier被选中的时候 抽取子弹 
func _on_phase02_enter() -> void:
	pass


#region SetUp
func repick_magazine() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	end_pick()

	# 安全装填，避免弹池数量不足导致崩溃
	var load_count = min(current_magazine_capacity, current_pick_bullet_set.size())
	for i in range(load_count):
		var bull = current_pick_bullet_set.pop_back()
		current_pick_magazine.append(bull)
	
	update_pick_magazine.emit(current_pick_magazine)
	is_locked = false

func end_pick() -> void:
	current_pick_bullet_set.append_array(current_pick_magazine)
	current_pick_bullet_set.shuffle()
	current_pick_magazine.clear()

#endregion

#region Operation
#===卡片操作===
func card_being_clicked(_card : Card):
	print(_card.name)
	var _data = _card.data
	
	# 检查该卡片对应的数据是否在 current_pick_magazine 中
	var index := current_pick_magazine.find(_data) #提升为全局变量？
	if index == -1:
		print("❌ 未找到卡片对应的数据")
		return

	print("✅ 找到卡片数据，应用修改器...")

	##深度拷贝
	#var new_data = _data.duplicate(true) as BulletData
	#var _modifier = current_selected_modifier #TODO 这里需要确认是选中了modifier
	#new_data.modifiers.append(_modifier) #添加这个修改器 
	#
	## 替换掉旧数据
	#current_pick_magazine[index] = new_data
	#print("🔁 已更新子弹数据:", new_data)

#1015 先做一版替换整个子弹数据的 
	if !current_selected_data:
		print("❌ 未选中卡片数据")
		return
	
	var confirmed_panel = PanelServer.\
	show_confirmation("确认覆盖这枚子弹吗？", "子弹（A）将会被替换成子弹（B）", \
	_override_bullet.bind(index), func() : pass)



#endregion
#endregion


#region PHASE03
func _on_phase03_enter() -> void:
	pass


#region SetUp
#弹出确认应用子弹的窗口 
func _show_confirmation() -> void:
	pass

#endregion

#region Operation
func _override_bullet(index : int) -> void:
	current_pick_magazine[index] = current_selected_data
	end_pick()
	update_pick_bullet_set.emit(current_pick_bullet_set)
	update_pick_magazine.emit(current_pick_magazine)
	
	print("🔁 已更新子弹数据:", current_selected_data.BulletName)

#endregion

#endregion




#===内部函数====
#region internal_function
#region CardManager
#根据bullet_set 指定 manager 生成卡片
func _on_picked_card_spwan(arr : Array[BulletData], _manager : CardsManager, ) -> void:
	CardServer.reset_card_manager(_manager)
	
	for bd in arr:
		var bull = DataContainer.new()
		bull.data = bd
		CardServer.manager_add_cards(_manager, bull)
#endregion

#endregion


#===按下按钮===
#region ButtonPress
func _on_close_work_shop_pressed() -> void:
	close_workshop()

func _on_repick_magazine_pressed() -> void:
	#这里要添加条件 才能重选弹夹
	repick_magazine()


#endregion
