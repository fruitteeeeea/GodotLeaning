class_name DungeonLayout
extends RefCounted #需要在这里提交一个字典 包含房间的各种信息 

@export var config : DungeonConfig #存储着关于房间生成规则的信息 

var rooms: Array[RoomData] = []
var grid: Dictionary = {}# Dictionary[Vector2i, int] -> room_id
var rng := RandomNumberGenerator.new()
var start_pos := Vector2i(0, 0)

var path : Array[Vector2i] = []
var main_ids : Array[int] = []
var side_ids : Array[int] = []

func generate(_config) -> Array[RoomData]:
	config = _config
	
	rooms.clear()
	grid.clear()

	_create_room(start_pos, RoomData.RoomType.START)
	_generate_main_path(config.min_path_len)
	_generate_side_branches(config.min_rooms, config.max_rooms)
	_assign_room_difficulty() #注意一下顺序 提前分配好房间难度 
	_assign_room_types(config.min_path_len)
	_compute_door_masks()
	
	return rooms


func _generate_main_path(min_path_len : int):
	var current := start_pos
	
	# 主线：随机游走直到长度达到 min_path_len
	path = [current]
	while path.size() < min_path_len:
		current = _random_neighbor_step(current, true)
		if not grid.has(current): #确保周围格子没有被占用 
			path.append(current)
			_create_room(current)
			_connect_rooms(path[-2], current) # 主线必连

	# 记录主线 id
	for p in path:
		main_ids.append(grid[p])


func _generate_side_branches(min_rooms : int, max_rooms : int):
	# 分支：从主线若干点出发扩展 #注意 min_path_len 的长度要和min和max保持对应 不然会卡死
	while rooms.size() < rng.randi_range(min_rooms, max_rooms): 
		var anchor = path[rng.randi_range(1, path.size()-2)]
		var branch_len := rng.randi_range(1, 3)
		var pos = anchor
		for i in branch_len:
			var nxt = _random_neighbor_step(pos, false)
			if not grid.has(nxt):
				_create_room(nxt)
				_connect_rooms(pos, nxt) # 分支必连
				_maybe_connect_to_other_neighbors(pos) # 有概率额外连门
				pos = nxt
				
				side_ids.append(grid[nxt])
			else :
				break

# 建立邻居与难度（基于曼哈顿距起点）
func _assign_room_difficulty():
	for r in rooms: #TODO 基于不同的难度 难度3的房间保持在一定数量 
		#r.neighbors = _find_neighbors(r.grid_pos)
		r.difficulty = r.grid_pos.distance_to(start_pos)


func _assign_room_types(min_path_len):
	# 选 Boss：离起点最远的普通房
	var boss = _find_boss_room()
	boss.type = RoomData.RoomType.BOSS #补充 最好为主线房间的终点 

	# 选宝物房：中等距离的普通房（不与 Boss 相邻）
	var candidates := rooms.filter(func(r): #筛选出符合条件的房间
		return r.type == RoomData.RoomType.NORMAL and r.difficulty >= min_path_len/2 and not _adjacent_to_type(r, RoomData.RoomType.BOSS))
	if candidates.size() > 0:
		candidates.shuffle()
		candidates[0].type = RoomData.RoomType.TREASURE #补充（最好为主线房间的一级衍生房间

	# 商店：与宝物房不同、靠近主线的普通房
	var shops := rooms.filter(func(r): return r.type == RoomData.RoomType.NORMAL and r.difficulty >= min_path_len/2 - 1)
	if shops.size() > 0:
		shops.shuffle()
		shops[0].type = RoomData.RoomType.SHOP #补充（最好为主线房间的二级衍生房间

	## 隐藏房：寻找“被 >=3 个房包围”的空位再回填 #TODO 隐藏房间还未设置 connect
	#var secret_spots := _find_secret_spots(3)
	#if secret_spots.size() > 0:
		#var pos := secret_spots[0]
		#_create_room(pos, RoomData.RoomType.SECRET)
##
	## 超级隐藏：恰好只有 1 个邻居的空位
	#var ssecret := _find_secret_spots(1, 1)
	#if ssecret.size() > 1:
		#_create_room(ssecret[0], RoomData.RoomType.SUPER_SECRET)

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
 #随机寻找房间 
func _random_neighbor_step(pos: Vector2i, avoid_backtrack := true) -> Vector2i:
	var dirs := [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)] #TODO 主线房间最好有一个大方向 
	dirs.shuffle()
	for d in dirs:
		var np = pos + d
		if abs(np.x - start_pos.x) > config.width/2: continue #这段代码保证房间不会超出边界
		if abs(np.y - start_pos.y) > config.height/2: continue
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

func _adjacent_to_type(r: RoomData, t: int) -> bool: #可以检测临近的房间是否为指定类型 
	for nid in r.neighbors:
		if rooms[nid].type == t:
			return true
	return false

#寻找Boss房间
func _find_boss_room() -> RoomData:
	var max_room: RoomData = null
	for r in rooms:
		if max_room == null or r.difficulty > max_room.difficulty:
			max_room = r
	
	return max_room
