extends Room

@onready var color_rect: ColorRect = $ColorRect

@export var color_list :={
}

func _ready() -> void:
	var id = room_info.depth
	color_rect.color = color_list[id]
