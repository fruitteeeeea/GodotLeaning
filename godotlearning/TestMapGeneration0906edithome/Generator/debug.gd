extends Node

@onready var dungeon_generator: DungeonGenerator = $".."

func _spwan_rooms_color():
	var current_id := 1
	for i in dungeon_generator.main_ids:
		var r = dungeon_generator.rooms[i]
		var room = dungeon_generator._room_node(r.id)
		var cr = ColorRect.new()
		var lab = Label.new()
		lab.text = str(current_id)
		cr.color = Color.RED
		cr.set_anchors_preset(Control.PRESET_CENTER)
		cr.self_modulate *= .5
		cr.size = Vector2.ONE * 128
		room.add_child(cr)
		room.add_child(lab)
		
		current_id += 1
