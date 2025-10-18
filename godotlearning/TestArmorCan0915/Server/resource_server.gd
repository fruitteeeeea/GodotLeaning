extends Node
#存放资源的路径。

var modifier_dic : Dictionary [int, Array] = {
	1 : [preload("res://TestArmorCan0915/TestResource/BulletData/FlameBllet.tres"), preload("res://TestArmorCan0915/TestResource/BulletData/HealBullet.tres")],
	2 : [],
	3 : [],
}


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		get_current_level_modifier(1)

func get_current_level_modifier(_level : int) -> BulletData:
	var res = null
	res = modifier_dic[_level].pick_random() 
	return res
