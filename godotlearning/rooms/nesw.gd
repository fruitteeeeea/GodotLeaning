extends Node2D
class_name Room

var room_info : RoomData

@onready var area_2d: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.area_entered.connect(_on_area_2d_area_entered)


func _on_area_2d_area_entered(area: Area2D) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.move_to_target_pos(global_position)
