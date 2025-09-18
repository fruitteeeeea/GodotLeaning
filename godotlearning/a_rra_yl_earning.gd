extends Node2D

@export var arr := []
@export var arr2 := []

@onready var label: Label = $CanvasLayer/Control/VBoxContainer/Label
@onready var label_2: Label = $CanvasLayer/Control/VBoxContainer/Label2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generated_nb()


func generated_nb():
	var index = 1
	for i in range(5):
		var nb : String
		if index == 5:
			nb = "##"
		else :
			nb = str(randi_range(0, 5))
		
		index += 1
		arr.append(nb)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(arr)
	label_2.text = str(arr2)


func _on_button_pressed() -> void:
	generated_nb()


func _on_button_2_pressed() -> void:
	for i in range(5):
		if arr.is_empty():
			break
			
		arr2.append(arr.pop_front())
		await get_tree().create_timer(.1).timeout


func _on_button_3_pressed() -> void:
	arr.shuffle()
