class_name DungeonGenerator
extends Node2D

@export var config: DungeonConfig
@onready var dungeon_builder: DungeonBuilder = $DungeonBuilder

@export var rooms := []

func _ready():
	var layout = DungeonLayout.new()
	rooms = layout.generate(config)
	dungeon_builder.build(rooms, config.room_size, config)
