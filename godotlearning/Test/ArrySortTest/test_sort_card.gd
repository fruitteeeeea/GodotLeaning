extends Control

@onready var label: Label = $PanelContainer/VBoxContainer/Label
@onready var label_2: Label = $PanelContainer/VBoxContainer/Label2
@onready var label_3: Label = $PanelContainer/VBoxContainer/ColorRect/Label3
@onready var color_rect: ColorRect = $PanelContainer/VBoxContainer/ColorRect

var data : TestSortData

@export var color_list : Array[Color] = []

func _ready() -> void:
	if data:
		label.text = data.bullet_type
		label_2.text = data.element_type
		label_3.text = str(data.rarity)
		
		var label_color : Color
		match data.rarity:
			1:
				label_color = color_list[0]
			2:
				label_color = color_list[1]
			3:
				label_color = color_list[2]
			4:
				label_color = color_list[3]

		color_rect.color = label_color
