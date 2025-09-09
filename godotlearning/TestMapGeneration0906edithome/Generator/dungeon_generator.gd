extends GeneratorBase
#class_name DungeonGenerator

#可以加入波坍塌函数来寻求和回溯随机生成结果

@export var room_scene_by_mask := { #这个根据门掩码来生成对应的房间思路可以借用 
	1:  preload("res://rooms/N.tscn"),
	2:  preload("res://rooms/E.tscn"),
	4:  preload("res://rooms/S.tscn"),
	8:  preload("res://rooms/W.tscn"),
	3:  preload("res://rooms/NE.tscn"),
	5:  preload("res://rooms/NS.tscn"),
	9:  preload("res://rooms/NW.tscn"),
	6:  preload("res://rooms/ES.tscn"),
	10: preload("res://rooms/EW.tscn"),
	12: preload("res://rooms/SW.tscn"),
	7:  preload("res://rooms/NES.tscn"),
	11: preload("res://rooms/NEW.tscn"),
	13: preload("res://rooms/NSW.tscn"),
	14: preload("res://rooms/ESW.tscn"),
	15: preload("res://rooms/NESW.tscn"),
}

# 简化示例：敌人库按难度抽样
var enemy_pools := {
	0: [preload("res://TestMapGeneration0906edithome/Unit/enemy_0.tscn")],
	2: [preload("res://TestMapGeneration0906edithome/Unit/enemy_2.tscn")],
	4: [preload("res://TestMapGeneration0906edithome/Unit/enemy_4.tscn")],
}

@export var room_size := Vector2(256, 256) #房间尺寸

@export var min_rooms := 10 
@export var max_rooms := 18
@export var min_path_len := 6 #迷宫房间数量的重要参数 

@export var rng_seed := 123456 #TODO 这个种子似乎没有起作用 


var main_ids := [] #主线房间 
var side_ids := [] #衍生房间

#其他装饰房间
var special_rooms := {
	"shop": preload("res://rooms/Unit/Shop.tscn"),
	"treasure": preload("res://rooms/Unit/Treasure.tscn"),
}

func _ready():
	rng.seed = rng_seed
	_generate_layout()
	_assign_room_types()
	_compute_door_masks()
	_instantiate_rooms()
	_populate_content()

func _generate_layout():
	rooms.clear(); grid.clear()
	var current := start_pos
	_create_room(current, RoomData.RoomType.START)

	# 主线：随机游走直到长度达到 min_path_len
	var path := [current]
	while path.size() < min_path_len:
		current = _random_neighbor_step(current, true)
		if not grid.has(current): #确保周围格子没有被占用 
			path.append(current)
			_create_room(current)
			_connect_rooms(path[-2], current) # 主线必连
	
	# 记录主线 id
	for p in path:
		main_ids.append(grid[p])

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
	for r in rooms: #TODO 基于不同的难度 难度3的房间保持在一定数量 
		#r.neighbors = _find_neighbors(r.grid_pos)
		r.difficulty = r.grid_pos.distance_to(start_pos)

#寻找邻居 
func _find_neighbors(pos: Vector2i) -> Array[int]:
	var ids : Array[int] = []
	var offsets := {
		Vector2i(0,-1): 1,  # N
		Vector2i(1,0): 2,   # E
		Vector2i(0,1): 4,   # S
		Vector2i(-1,0): 8,  # W
	}
	for off in offsets.keys():
		var np = pos + off
		if grid.has(np): 
			ids.append(grid[np])
	return ids


func _assign_room_types():
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


func _find_boss_room() -> RoomData:
	var max_room: RoomData = null
	for r in rooms:
		if max_room == null or r.difficulty > max_room.difficulty:
			max_room = r
	return max_room

#隐藏房间
func _find_secret_spots(min_adjacent := 3, max_adjacent := 4) -> Array[Vector2i]:
	var spots : Array[Vector2i] = []
	var dirs := [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]
	# 在当前边界的内圈查找空位
	for x in range(start_pos.x - width/2, start_pos.x + width/2 + 1):
		for y in range(start_pos.y - height/2, start_pos.y + height/2 + 1):
			var p := Vector2i(x,y)
			if grid.has(p): continue
			var cnt := 0
			for d in dirs:
				if grid.has(p + d): cnt += 1
			if cnt >= min_adjacent and cnt <= max_adjacent:
				spots.append(p)
			
	spots.shuffle()
	return spots #这里需要同时返回隐藏房间点和隐藏房间连接的房间

##===下面是正式开始实例化房间===

func _instantiate_rooms():
	var cell_size := room_size # 你的房间世界尺寸
	for r in rooms:
		#if r.neighbors.size() == 0:
			#return
		var scene = room_scene_by_mask.get(r.door_mask)
		var inst = scene.instantiate() as Room
		add_child(inst)
		inst.position = Vector2(r.grid_pos.x * cell_size.x, r.grid_pos.y * cell_size.y)
		inst.set_meta("room_id", r.id) #他这里是统一实例化的 
		
		inst.room_info = r #赋予房间信息 
		
		#_apply_room_theme(inst, r.type) #装饰房间 

#为房间填充内容
func _populate_content():
	for r in rooms:
		match r.type:
			RoomData.RoomType.NORMAL: #TODO 重写一些对应房间生成的物品 
				#_spawn_enemies(r, lampi(1 + r.difficulty/2, 1, 6))
				_spawn_enemies(r, 3, "普通房间")
			RoomData.RoomType.TREASURE:
				_spawn_treasure(r)
				_spawn_enemies(r, 0, "宝物房间")
			RoomData.RoomType.SHOP:
				#_spawn_shop(r)
				_spawn_shop(r)
				_spawn_enemies(r, 0, "商店房间")
			RoomData.RoomType.BOSS:
				#_spawn_boss(r)
				_spawn_enemies(r, 3, "BOSS房间")
			RoomData.RoomType.SECRET, RoomData.RoomType.SUPER_SECRET:
				#_spawn_secret_rewards(r)
				_spawn_enemies(r, 3, "隐藏房间")


func _spawn_enemies(r: RoomData, base_count: int = 3, t : String = "普通房间"):
	var inst = _room_node(r.id)
	var count := base_count
	for i in count:
		var tier := 0
		if r.difficulty >= 4: tier = 4
		elif r.difficulty >= 2: tier = 2 #根据当前房间与初始房间的距离计算出敌人的难度 
		var pool = enemy_pools.get(tier, enemy_pools[0])
		var scene = pool[rng.randi() % pool.size()]
		var e = scene.instantiate()
		inst.add_child(e)
		
		var label = Label.new()
		label.text = t
		inst.add_child(label)
		
		e.global_position = _random_point_in_room(inst)

#生成商店房间
func _spawn_shop(r: RoomData):
	var inst = _room_node(r.id)
	var shop = special_rooms["shop"].instantiate()
	inst.add_child(shop)

#生成宝箱房间
func _spawn_treasure(r: RoomData):
	var inst = _room_node(r.id)
	var treasure = special_rooms["treasure"].instantiate()
	inst.add_child(treasure)
