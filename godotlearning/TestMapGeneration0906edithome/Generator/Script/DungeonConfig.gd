class_name DungeonConfig
extends Resource

@export var rng_seed: int = 123456

@export var width: int = 100
@export var height: int = 100
@export var room_size: Vector2 = Vector2(256, 256)

@export var min_rooms: int = 10
@export var max_rooms: int = 18
@export var min_path_len: int = 6

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

@export var enemy_pools: Dictionary = {
	0: [preload("res://TestMapGeneration0906edithome/Unit/enemy_0.tscn")],
	2: [preload("res://TestMapGeneration0906edithome/Unit/enemy_2.tscn")],
	4: [preload("res://TestMapGeneration0906edithome/Unit/enemy_4.tscn")],
}

@export var special_rooms: Dictionary = {
	"shop": preload("res://rooms/Unit/Shop.tscn"),
	"treasure": preload("res://rooms/Unit/Treasure.tscn"),
}
