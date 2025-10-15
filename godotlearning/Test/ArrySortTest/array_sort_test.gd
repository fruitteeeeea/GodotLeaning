extends Node2D

@onready var label: Label = $Label

@onready var test_sort_card: Control = $TestSortCard
@onready var card_array: HBoxContainer = $CardArray

var current_arry : Array[TestSortData] = []
var descending := false

func random_pick_card():
	current_arry.clear()
	
	for i in range(10):
		var _data = TestSortData.new()
		_data.bullet_type = ["normal", "summon", "element"].pick_random()
		_data.element_type = ["physics", "fire", "ice"].pick_random()
		_data.rarity = [1, 2, 3, 4].pick_random()
		current_arry.append(_data)
	
	sort_bullet()


func respwan_card() -> void:
	for i in card_array.get_children():
		i.queue_free()
	
	for i in current_arry:
		var card = test_sort_card.duplicate()
		card.data = i
		card_array.add_child(card)


func _on_button_pressed() -> void:
	random_pick_card()
	respwan_card()
	#current_arry.clear()
	#
	#for i in range(10):
		#var c = randi() % 100 + 1 
#
		#current_arry.append(c)
	#
	#update_label_text()


func _on_button_2_pressed() -> void:
	#current_arry.sort()
	#update_label_text()

	descending = !descending
	sort_bullet("type")
	respwan_card()
	
func _on_button_3_pressed() -> void:
	descending = !descending
	sort_bullet("rarity")
	respwan_card()

func update_label_text() -> void:
	var final_text = ",".join(current_arry)
	label.text = final_text


func sort_bullet(_mode := "combined"):
	BulletSorter.sort_bullets(current_arry, _mode)
	if descending:
		current_arry.reverse()
