extends Node2D
class_name DungeonBuilder

#@export var room_scene_by_mask: Dictionary
#@export var special_rooms: Dictionary
#@export var enemy_pools: Dictionary

var rng := RandomNumberGenerator.new()

@export var config : DungeonConfig #存储着关于房间生成规则的信息
@export var use_test_room := false

#实例化房间
func build(rooms: Array[RoomData], room_size: Vector2i, _config : DungeonConfig):
	config = _config
	
	for r in rooms:
		var scene = config.room_scene_by_mask.get(r.door_mask)
		
		if use_test_room: #DEBUG相关
			scene = preload("res://TestMapGeneration0906edithome/test_room.tscn")

		var inst = scene.instantiate()
		
		inst.position = r.grid_pos * room_size
		inst.set_meta("room_id", r.id)
		inst.room_info = r
		
		add_child(inst)
	
	populate_content(rooms)

#为房间填充内容
func populate_content(rooms: Array[RoomData]):
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
		var pool = config.enemy_pools.get(tier, config.enemy_pools[0])
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
	var shop = config.special_rooms["shop"].instantiate()
	inst.add_child(shop)

#生成宝箱房间
func _spawn_treasure(r: RoomData):
	var inst = _room_node(r.id)
	var treasure = config.special_rooms["treasure"].instantiate()
	inst.add_child(treasure)


func _room_node(room_id: int) -> Node2D:
	for c in get_children():
		if c.has_meta("room_id"):
			if c.get_meta("room_id") == room_id:
				return c
	return null


func _random_point_in_room(room: Node2D) -> Vector2:
	# 先拿房间的区域范围（这里假设房间场景的大小是 512x320）
	var size = Vector2(128, 128) #标记怪物位置 以房间大小为准 
	
	# 在这个矩形范围里随机一个点
	var local_x = rng.randf_range(-size.x/2, size.x/2)
	var local_y = rng.randf_range(-size.y/2, size.y/2)

	var pos = room.position + Vector2(local_x, local_y)
	return pos
