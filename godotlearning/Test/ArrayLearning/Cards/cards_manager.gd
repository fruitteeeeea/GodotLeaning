extends Node2D

@onready var cards: Control = $".."

const CARD = preload("res://Test/ArrayLearning/Cards/card.tscn")
@onready var debug_drawer: Node2D = $"../DebugDrawer"

@export var min_x := 64.0
@export var max_x := 576.0
@export var max_spacing := 40

@export var cards_posx_info := {} # {card_node: Vector2}
var current_cards := 0

func _ready() -> void:
	operate_cards(1)


var amplitude := 5  # 正弦波振幅（上下偏移距离）
var frequency := 2.0  # 波动速度
var phase_offset := 0.5 # 每张牌之间的相位差

func _process(delta: float) -> void:
	var i := 0
	var time = Time.get_ticks_msec() / 1000.0 # 秒为单位
	for card in cards_posx_info.keys():
		var base_pos = cards_posx_info[card]  # 基础点（只含 X 坐标）
		var y_offset = sin(time * frequency + i * phase_offset) * amplitude
		card.position = Vector2(base_pos.x, base_pos.y + y_offset)
		i += 1


func operate_cards(n := 0):
	debug_drawer.clear_circles()
	
	# 更新卡片数量（不能小于 0）
	current_cards = max(current_cards + n, 0)

	# 计算新位置列表
	var positions: Array = get_card_positions(current_cards)

	# 先更新 Debug 圆圈
	for p in positions:
		debug_drawer.add_circle(Vector2(p, 0))
		
	# 如果只是刷新位置，不需要增减
	if n == 0:
		_update_card_positions(positions)
		return
	
	if n > 0: # 添加卡片
		for i in range(n):
			var card = CARD.instantiate()
			
			card.hovered.connect(_on_card_hovered)
			card.unhovered.connect(_on_card_unhovered)
			
			add_child(card)
			
			# 把卡片放到对应位置
			var pos = positions[cards_posx_info.size()]
			card.position = Vector2(pos, 0)
			
			# 记录字典
			cards_posx_info[card] = card.position
	
	elif n < 0: # 删除卡片
		for i in range(-n):
			if cards_posx_info.size() == 0:
				break
			var card = cards_posx_info.keys()[-1] # 最后一个卡片
			cards_posx_info.erase(card)
			card.queue_free()
	
	# 重新对齐剩余卡片的位置
	_update_card_positions(positions)
	#_update_card_positions(get_arc_positions(current_cards, 300, PI/3))


func _update_card_positions(positions: Array) -> void:
	var i := 0
	for card in cards_posx_info.keys():
		if i >= positions.size():
			break
		
		#var target_pos = positions[i]["pos"]
		#var target_rot = positions[i]["rot"]
		#card.move_to(target_pos)     # 平滑移动
		#card.rotate_to(target_rot)   # 需要在 Card.gd 里加 rotate_to()
		#cards_posx_info[card] = target_pos
		
		var target_pos = Vector2(positions[i], card.position.y) #这里不要修改posy
		
		card.move_to(target_pos)  # 调用卡片内部 tween
		cards_posx_info[card] = target_pos
		i += 1

# ===== 弧线排列：返回位置 + 旋转 =====
func get_arc_positions(num_cards: int, radius: float, arc_angle: float) -> Array:
	var positions: Array = []
	var center_angle = PI / 2  # 中心朝上，可以改成 PI/4 之类的

	for i in range(num_cards):
		var t = 0.0
		if num_cards > 1:
			t = float(i) / (num_cards - 1)
		var angle = center_angle - arc_angle / 2 + t * arc_angle

		var pos = Vector2(cos(angle), -sin(angle)) * radius
		positions.append({
			"pos": pos,
			"rot": angle - PI/2  # 卡片旋转方向对齐弧度
		})
	return positions


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

#====管理卡片悬停====
@export var hover_spacing := 60

var hover_index := -1  # 当前鼠标悬停的卡片索引，-1 表示没有

func _on_card_hovered(card: Node) -> void:
	hover_index = cards_posx_info.keys().find(card)
	_update_card_positions(get_card_positions(cards_posx_info.size()))

func _on_card_unhovered(card: Node) -> void:
	hover_index = -1
	_update_card_positions(get_card_positions(cards_posx_info.size()))
