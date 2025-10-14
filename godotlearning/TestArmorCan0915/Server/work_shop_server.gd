extends Control
#用于修改玩家弹夹的通道 

signal update_pick_bullet_set(arr : Array[BulletData])
signal update_pick_magazine(arr : Array[BulletData])

#修改玩家弹夹步骤 

#工房修改玩家 WeaponSet 的顺序
#1. 锁定 WeaponS et
#2. 获取玩家当前 Weapon Set
#3. 对玩家当前 Weapon Set 进行修改 
#4. 设置玩家当前 Weapon Set
#5. 解锁 Weapon Set


#工房获取 Modifier 的顺序 
#1. 获取当前可获取内容等级 

var is_modifiy_mod := false
var is_locked := false #进行危险操作的时候 可以先锁住

#===Test相关===
@export var test_bullet_data01 : BulletData 
@export var test_bullet_data02 : BulletData 

@export var test_modifier : BulletModifierData

func _ready() -> void:
	get_player_current_weaponset()
	
	for i in bullet_modifier.get_children():
		if i is Button:
			i.pressed.connect(_updata_selected_button.bind(i))

#region WeaponSet

var current_pick_bullet_set : Array[BulletData] = []

var curretn_bullet_pool_capacity : int
var current_magazine_capacity : int

var current_pick_magazine : Array[BulletData] = []

#获取玩家当前的 武器配置 （子弹配置 弹仓容量 弹夹容量）
func get_player_current_weaponset() -> void:
	current_pick_bullet_set = PlayerWeaponServer.get_bullet_set() 
	update_pick_bullet_set.emit(current_pick_bullet_set)
	
	curretn_bullet_pool_capacity = PlayerWeaponServer.get_bullet_pool_capacity()
	current_magazine_capacity = PlayerWeaponServer.get_magazine_capacity()


func repick_magazine() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	end_pick()
	#current_pick_bullet_set.append_array(current_pick_magazine)
	#current_pick_bullet_set.shuffle()
	#current_pick_magazine.clear()
	
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

#region WorkShop
@onready var bullet_modifier: GridContainer = $PanelContainer/BulletModifier

func apply_modifier_to_bullet():
	pass


func _updata_selected_button(i : Button) -> void:
	print(i.name)


#endregion



var current_selected_data : BulletData
var current_selected_modifier : BulletModifierData

#===卡片操作===
func card_being_clicked(_card : Card):
	print(_card.name)
	var _data = _card.data
	
	# 检查该卡片对应的数据是否在 current_pick_magazine 中
	var index := current_pick_magazine.find(_data)
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
		
	current_pick_magazine[index] = current_selected_data
	end_pick()
	update_pick_bullet_set.emit(current_pick_bullet_set)
	update_pick_magazine.emit(current_pick_magazine)
	
	print("🔁 已更新子弹数据:", current_selected_data.BulletName)



#===界面按钮===
func _on_repick_magazine_pressed() -> void:
	repick_magazine()


func _on_fire_bullet_pressed() -> void:
	current_selected_data = test_bullet_data01


func _on_ice_bullet_pressed() -> void:
	current_selected_data = test_bullet_data02
