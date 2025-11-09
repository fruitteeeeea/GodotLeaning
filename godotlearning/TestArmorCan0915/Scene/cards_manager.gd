extends Node2D
class_name CardsManager

signal card_being_clicked(card : Card) #卡片被点击

#@onready var debug_drawer: Node2D = $"../DebugDrawer"

@export var horizontal_arran := true

@export var overall_width := 512.0 #会以card manager自身为中心 向左右两边扩散 
@export var min_x := overall_width / 2 * -1   #最左边的点
@export var max_x := overall_width / 2        #最右边的点

@export var max_spacing := 65     #最大间隔
@export var hover_spacing := 80   #悬停间隔

@export_category("CardManagerFunc")
@export var can_charge := false
@export var can_colddown : = false
@export var can_hover := false
@export var can_click := false

var cards_posx_info := {}           # {card_node: Vector2}
var current_cards := 0
var hover_index := -1  # 当前鼠标悬停的卡片索引，-1 表示没有

# ---------------- 基础操作 ----------------
#增加卡片 
func add_cards(_card : Card = null,) -> void:
	add_child(_card)
	cards_posx_info[_card] = Vector2.ZERO  # 先放字典，等位置计算
	
	current_cards = max(current_cards + 1, 0) # 更新数量
	_update_card_positions(_get_card_positions(current_cards)) # 重新对齐剩余卡片的位置


#减少卡片 
func remove_cards(_card : Card = null) -> void: #TODO 改成私有变量
	var target_card: Card = _card
	
	if target_card:
		cards_posx_info.erase(target_card)
		target_card.outof_arry()

		current_cards = max(current_cards - 1, 0) # 更新数量
		_update_card_positions(_get_card_positions(current_cards)) # 重新对齐剩余卡片的位置


# ---------------- 位置计算 ----------------
func _get_card_positions(n: int) -> Array[float]: #仅仅计算位置 
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


# ---------------- 内部函数 ----------------
func _update_card_positions(positions: Array) -> void:
	#debug_drawer.clear_circles()   # 清空之前的
	var i := 0
	for card in cards_posx_info.keys():
		if i >= positions.size():
			break
		
		var target_pos : Vector2 
		if horizontal_arran: #判断是否为水平排布
			target_pos = Vector2(positions[i], 0) # 保持 Y 不动
		else :
			target_pos = Vector2(0, positions[i]) # 保持 X 不动

		card.move_to(target_pos)                  # 调用卡片内部 tween
		cards_posx_info[card] = target_pos
		
		#debug_drawer.add_circle(target_pos) # 在调试器上画圆圈
		i += 1


# ---------------- 卡片悬停 ----------------
func _on_card_hovered(card: Node) -> void:
	hover_index = cards_posx_info.keys().find(card)
	_update_card_positions(_get_card_positions(cards_posx_info.size()))


func _on_card_unhovered(card: Node) -> void:
	hover_index = -1
	_update_card_positions(_get_card_positions(cards_posx_info.size()))
