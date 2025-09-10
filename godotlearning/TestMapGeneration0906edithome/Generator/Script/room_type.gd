class_name RoomData
extends Resource

enum RoomType { START, NORMAL, BOSS, TREASURE, SHOP, CHALLENGE, DEVIL, SECRET, SUPER_SECRET }

@export var id: int
@export var grid_pos: Vector2i
@export var type: RoomType = RoomType.NORMAL
@export var door_mask: int = 0 # Bit: 1=N, 2=E, 4=S, 8=W
var neighbors: Array[int] = []
var difficulty: int = 0

var depth := 0
