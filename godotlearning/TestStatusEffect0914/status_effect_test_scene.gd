extends Node2D

@onready var dummy_00: CharacterBody2D = $Dummy00



func _on_button_pressed() -> void:
	var burn = preload("res://TestStatusEffect0914/Resource/burn001.tres")
	StatusEffectServer.apply_effect(dummy_00, burn)


func _on_button_2_pressed() -> void:
	var poison = preload("res://TestStatusEffect0914/Resource/pois001.tres")
	StatusEffectServer.apply_effect(dummy_00, poison)


func _on_button_3_pressed() -> void:
	var roar = preload("res://TestStatusEffect0914/Resource/stun001.tres")
	StatusEffectServer.apply_effect(dummy_00, roar)
