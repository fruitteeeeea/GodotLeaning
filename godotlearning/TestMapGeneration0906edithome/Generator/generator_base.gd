extends Node
class_name GeneratorBase

@export var width := 100
@export var height := 100 #限制格子边界 

@export var start_pos := Vector2i(0, 0)

var rng := RandomNumberGenerator.new()
@export var grid := {} # Dictionary[Vector2i, int] -> room_id
@export var rooms := [] # Array[RoomData]


 #随机寻找房间 
func _random_neighbor_step(pos: Vector2i, avoid_backtrack := true) -> Vector2i:
	var dirs := [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)] #TODO 主线房间最好有一个大方向 
	dirs.shuffle()
	for d in dirs:
		var np = pos + d
		if abs(np.x - start_pos.x) > width/2: continue #这段代码保证房间不会超出边界
		if abs(np.y - start_pos.y) > height/2: continue
		if avoid_backtrack and grid.has(np): continue
		return np
	# 兜底：随机方向
	return pos + dirs[0]

#创建房间数据  使用默认值 
func _create_room(pos: Vector2i, t := RoomData.RoomType.NORMAL):
	var rd := RoomData.new()
	rd.id = rooms.size()
	rd.grid_pos = pos
	rd.type = t
	rooms.append(rd)
	grid[pos] = rd.id

# 连接两个房间（双向）
func _connect_rooms(a: Vector2i, b: Vector2i) -> void:
	var room_a = grid[a]
	var room_b = grid[b]

	if not rooms[room_a].neighbors.has(room_b):
		rooms[room_a].neighbors.append(room_b)
	if not rooms[room_b].neighbors.has(room_a):
		rooms[room_b].neighbors.append(room_a)

# 有概率把某个房间和它的相邻房间连起来
func _maybe_connect_to_other_neighbors(pos: Vector2i, extra_prob: float = 0.25) -> void:
	var dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for d in dirs:
		var np = pos + d
		if grid.has(np):
			var room_a = rooms[grid[pos]]
			var room_b = rooms[grid[np]]
			if not room_a.neighbors.has(room_b.id):
				#if rng.randf() < extra_prob:
				if rng.randf() < 1:
					_connect_rooms(pos, np)
					print("额外连接房间")

#j计算门掩码 #关键函数 
func _compute_door_masks():
	var offset_to_bit := {
		Vector2i(0,-1): 1, Vector2i(1,0): 2, Vector2i(0,1): 4, Vector2i(-1,0): 8
	}
	for r in rooms:
		var mask := 0
		for off in offset_to_bit.keys():
			var np = r.grid_pos + off
			#if grid.has(np): 
			if grid.has(np) && r.neighbors.has(grid[np]): #这里再补充一下 确认这个点确实再 r 的 
				mask |= offset_to_bit[off] #在已知房间中寻找已经存在的房间 
		r.door_mask = mask

#===Tools工具===
func _adjacent_to_type(r: RoomData, t: int) -> bool: #可以检测临近的房间是否为指定类型 
	for nid in r.neighbors:
		if rooms[nid].type == t:
			return true
	return false


func _room_node(room_id: int) -> Node2D:
	for c in get_children():
		if c.has_meta("room_id"):
			if c.get_meta("room_id") == room_id:
				return c
	return null


func _random_point_in_room(room: Node2D) -> Vector2:
	# 先拿房间的区域范围（这里假设房间场景的大小是 512x320）
	var size = Vector2(128, 128)
	
	# 在这个矩形范围里随机一个点
	var local_x = rng.randf_range(-size.x/2, size.x/2)
	var local_y = rng.randf_range(-size.y/2, size.y/2)

	var pos = room.position + Vector2(local_x, local_y)
	return pos
