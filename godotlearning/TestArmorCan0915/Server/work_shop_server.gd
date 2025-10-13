extends Control
#用于修改玩家弹夹的通道 

#修改玩家弹夹步骤 

#从玩家当前 弹仓 中抽取 弹夹 数量子弹 
#获取 修改器 

@onready var bullet_modifier: GridContainer = $PanelContainer/BulletModifier

var current_pick_bullet_list := []
var current_pick_modifier_list := []

var current_selected_modifier : Button = null

func _ready() -> void:
	for i in bullet_modifier.get_children():
		if i is Button:
			i.pressed.connect(_updata_selected_button.bind(i))


func get_bullet_list():
	pass


func get_modifier_list():
	pass


func apply_modifier_to_bullet():
	pass


func _updata_selected_button(i : Button) -> void:
	print(i.name)
	current_selected_modifier = i
