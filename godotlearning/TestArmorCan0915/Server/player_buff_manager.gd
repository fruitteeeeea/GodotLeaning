extends Node2D

var activated_buff_list : Dictionary [Card, BulletData] = {}


func _ready() -> void:
	CardServer.card_fully_charge.connect(_add_buff)

func _add_buff(dc : Card) -> void:
	var _data = dc.data
	activated_buff_list[dc] = _data


func _remove_buff(dc : Card) -> void:
	activated_buff_list.erase(dc)
