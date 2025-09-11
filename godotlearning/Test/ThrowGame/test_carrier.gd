extends Node2D
class_name Carrier

var carrying: ThrowableObject = null

@onready var area_2d: Area2D = $Area2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var list = _get_nearby_item()
		var item : ThrowableObject
		if list.size() > 0:
			item = list[0]
			try_pickup(item)
	if event.is_action_pressed("mouse_right"):
		do_throw_to_mouse()



func _get_nearby_item() -> Array:
	var arr = []
	var list = area_2d.get_overlapping_bodies()
	for i in list:
		if i is ThrowableObject:
			arr.append(i)
	return arr


func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()


func do_throw_to_mouse() -> void:
	if carrying == null:
		return
	var dir = get_throw_dir()
	# 想要投掷 500 像素，总速度 900
	carrying.throw(dir, 500.0, 900.0)
	carrying = null


func try_pickup(item: Node) -> void:
	if carrying == null:
		item.pick_up(self)
		carrying = item


func get_throw_dir() -> Vector2:
	var dir = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),]
	return dir.pick_random()
