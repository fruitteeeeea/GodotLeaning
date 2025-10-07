extends Node
#管理卡片的服务器 

const CARD = preload("res://TestArmorCan0915/Cards/card.tscn") #卡片场景

@export var cards_manager_info : Dictionary = {
	#键 ： 卡片管理器
	#值 ： 卡片管理器的字典，分别对应卡片和对应节点 
	#作用：通过输入的节点 快速找到对应卡片 方便后续操作 
	#卡片只需要专注于卡片本身的操作 
}

#添加卡片管理器 
#1.添加路径 2.管理器 3.屏幕上的位置 4.水平位置 5.名称
func hud_add_manager(_path : String, _manager : CardsManager, _pos : Vector2, _heriozion : bool, _name : String):
	pass

#绑定卡片对应节点
func add_card_info():
	pass

#根据输入的管理器和节点 返回对应的卡片 
func find_card(_manager : CardsManager, _node : Node) -> Card:
	var card : Card = cards_manager_info[_manager][_node]
	if card:
		return card
	
	print("未找到对应卡片", _node)
	return null

#添加卡片 
#1. 添加卡片的管理器 2.添加或减少卡片的数量 3.卡片参数 4.卡片关联的节点 
func manager_operate_card(_manager : CardsManager, _card : Card, _node : Node, _nb : int,) -> void:
	_manager.operate_cards(_node, _card, _nb)
