extends Node
#管理卡片的服务器 

signal card_fully_charge(card : Card)
signal card_buff_finished(card : Card)

const CARD = preload("res://TestArmorCan0915/Cards/card.tscn") #卡片场景

@export var cards_manager_info : Dictionary = {
	#键 ： 卡片管理器  #值 ： 卡片管理器的字典，分别对应 节点 : 卡片
	#作用：通过输入的节点 快速找到对应卡片 方便后续操作 
	#卡片只需要专注于卡片本身的操作 
} #TODO 这个字典内置到manager里面。

#添加卡片管理器 
#1.添加路径 2.管理器 3.屏幕上的位置 4.水平位置 5.名称
func hud_add_manager(_path : String, _manager : CardsManager, _pos : Vector2, _heriozion : bool, _name : String):
	pass

#根据输入的管理器和节点 返回对应的卡片 
func find_card(_manager : CardsManager, _node : Node) -> Card:
	if !cards_manager_info.has(_manager) : return null #管理器 
	if !cards_manager_info[_manager].has(_node) : return null #管理器对应节点 
	if !cards_manager_info[_manager][_node] : return null
	
	var card : Card = cards_manager_info[_manager][_node]
	if card:
		return card
	
	print("未找到对应卡片", _node)
	return null

#重置卡片管理器 
func reset_card_manager(_manager : CardsManager,) -> void:
	_manager.cards_posx_info.clear()
	_manager.current_cards = 0
	for i in _manager.get_children():
		i.queue_free()
	#清空管理器对应信息
	if cards_manager_info.has(_manager) : cards_manager_info[_manager].clear() 


#添加卡片 
#1. 添加卡片的管理器 2.卡片关联的节点 3.卡片类型
func manager_add_cards(_manager : CardsManager, _node : Node) -> void:
	var card = CARD.instantiate() as Card
	
	if _node: #赋值数据 #确保node 拥有卡片需要的数据 
		card.data = _node.data
	
	#卡片充能
	if _manager.can_charge:
		var _d : BulletData = _node.data
		match _node.data.charger: #根据自身的充能类型 链接卡片充能信号 
			_d.ChargeEvent.ON_LOAD:
				PlayerBehaviorServer.player_load.connect(card._add_charge)
				card.tree_exiting.connect(func() : PlayerBehaviorServer.player_load.disconnect(card._add_charge))
			_d.ChargeEvent.ON_FIRE: 
				PlayerBehaviorServer.player_fire.connect(card._add_charge)
				card.tree_exiting.connect(func() : PlayerBehaviorServer.player_fire.disconnect(card._add_charge))
			_d.ChargeEvent.ON_HITT: 
				PlayerBehaviorServer.player_hitt.connect(card._add_charge)
				card.tree_exiting.connect(func() : PlayerBehaviorServer.player_hitt.disconnect(card._add_charge))
			_d.ChargeEvent.ON_KILL: 
				PlayerBehaviorServer.player_kill.connect(card._add_charge)
				card.tree_exiting.connect(func() : PlayerBehaviorServer.player_kill.disconnect(card._add_charge))
				
		
		#充能完成 移除卡片 
		card.card_progress_type = "Recharge"
		card.card_buff_activated.connect(func (): manager_remove_card(_manager, _node)) #卡片buff激活时 移除卡片 

	if _manager.can_colddown:
		card.card_progress_type = "ColdDown"
		card.card_buff_finished.connect(func (): manager_remove_card(_manager, _node)) #卡片buff结束时 移除卡片 


	#卡片悬停 
	if _manager.can_hover:
		card.hovered.connect(_manager._on_card_hovered) 
		card.mouse_entered.connect(card._on_hovered)
		
		card.unhovered.connect(_manager._on_card_unhovered)
		card.mouse_exited.connect(card._on_unhovered)
	
	_manager.add_cards(card)

	if !cards_manager_info.has(_manager): #初始化字典 #管理器对应的值是字典{节点 ： 卡片}
		cards_manager_info[_manager] = {} 
	
	cards_manager_info[_manager][_node] = card #字典添加对应卡片的节点
	#card.card_removed.connect(_node.queue_free)
	_node.tree_exiting.connect(func (): cards_manager_info[_manager].erase(_node))


func manager_remove_card(_manager : CardsManager, _node : Node,) -> void:
	var card = find_card(_manager, _node) #看看是否有对应卡片 
	if card:
		cards_manager_info[_manager].erase(_node) #！先删除键
		_manager.remove_cards(card) #寻找到节点对应的卡片 
