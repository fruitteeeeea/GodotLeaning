extends Node2D
class_name CardsManager

const CARD = preload("res://TestArmorCan0915/Cards/card.tscn")
@onready var debug_drawer: Node2D = $"../DebugDrawer"


@export var overall_width := 512.0 #会以card manager自身为中心 向左右两边扩散 
@export var min_x := overall_width / 2 * -1
@export var max_x := overall_width / 2

@export var max_spacing := 65

@export var cards_posx_info := {}           # {card_node: Vector2}
@export var card_nodes: Dictionary = {}     # {card: node}
@export var current_cards := 0


# ---------------- 基础操作 ----------------
func reset_cards():
	cards_posx_info.clear()
	card_nodes.clear()
	current_cards = 0
	for i in get_children():
		i.queue_free()

# 增/减/整理卡片
func operate_cards(_bull : BulletInstance = null, _card : Card = null, n := 0):
	# 更新数量
	current_cards = max(current_cards + n, 0)
	
	if n > 0: # 添加卡片
		for i in range(n):
			_add_cards(_bull)
	
	elif n < 0: # 删除卡片
		for i in range(-n):
			if _card:
				_remove_cards(null, _card)
			else :
				_remove_cards(_bull)
	
	# 重新对齐剩余卡片的位置
	_update_card_positions(get_card_positions(current_cards))

# ---------------- 内部函数 ----------------

func _add_cards(_bull : BulletInstance = null) -> void:
	var card = CARD.instantiate() as Card
	
	if _bull:
		card.data = _bull.data
	
	card.card_full_charged.connect(operate_cards.bind(-1)) #卡片充能完成时 移除卡片 
	
	card.hovered.connect(_on_card_hovered)
	card.unhovered.connect(_on_card_unhovered)
	
	add_child(card)
	
	cards_posx_info[card] = Vector2.ZERO  # 先放字典，等位置计算
	card_nodes[card] = _bull   # 绑定对应的 BulletInstance


func _remove_cards(_bull: BulletInstance = null, _card : Card = null) -> void:
	var target_card: Card = null

	if _bull: # 根据 BulletInstance 找卡片
		for card in card_nodes.keys():
			if card_nodes[card] == _bull:
				target_card = card
				break
	else: # 随机移除一张
		if cards_posx_info.size() > 0:
			target_card = cards_posx_info.keys().pick_random()

	if _card: #如果参数传了card
		target_card = _card

	if target_card:
		cards_posx_info.erase(target_card)
		card_nodes.erase(target_card)
		target_card.outof_arry()


func _update_card_positions(positions: Array) -> void:
	debug_drawer.clear_circles()   # 清空之前的
	var i := 0
	for card in cards_posx_info.keys():
		if i >= positions.size():
			break
		
		var target_pos = Vector2(positions[i], 0) # 保持 Y 不动
		card.move_to(target_pos)                  # 调用卡片内部 tween
		cards_posx_info[card] = target_pos
		
		debug_drawer.add_circle(target_pos) # 在调试器上画圆圈
		i += 1

# ---------------- 位置计算 ----------------

func get_card_positions(n: int) -> Array[float]: #仅仅计算位置 
	var positions: Array[float] = []
	if n <= 0:
		return positions
	if n == 1:
		positions.append((min_x + max_x) / 2.0)
		return positions
	
	var width = max_x - min_x
	var spacing = max_spacing
	
	# 判断是否需要压缩
	if (n - 1) * spacing > width:
		spacing = width / float(n - 1)
	
	var total_width = (n - 1) * spacing
	var start_x = (min_x + max_x) / 2.0 - total_width / 2.0
	
	for i in range(n):
		var x = start_x + i * spacing

		if hover_index >= 0:
			var extra = (hover_spacing - spacing)
			
			if i < hover_index:
				# 悬停卡片左边的卡片整体往左偏移
				x -= extra * 0.5
			elif i > hover_index:
				# 悬停卡片右边的卡片整体往右偏移
				x += extra * 0.5
			# i == hover_index 的卡片保持在中间
			
		positions.append(x)
		
	return positions

# ---------------- 卡片悬停 ----------------
@export var hover_spacing := 60

var hover_index := -1  # 当前鼠标悬停的卡片索引，-1 表示没有

func _on_card_hovered(card: Node) -> void:
	hover_index = cards_posx_info.keys().find(card)
	_update_card_positions(get_card_positions(cards_posx_info.size()))

func _on_card_unhovered(card: Node) -> void:
	hover_index = -1
	_update_card_positions(get_card_positions(cards_posx_info.size()))
