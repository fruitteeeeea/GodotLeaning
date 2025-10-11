extends Node2D

var activated_buff_list : Dictionary [DataContainer, BulletData] = {}


func get_all_activated_buff() -> String: #获取所有当前生效的buff
	var list = []
	for i in activated_buff_list.keys():
		var name = activated_buff_list[i].BulletName
		list.append(name)
	
	var result: String = ", ".join(list)  # 用逗号+空格连接
	return result


func add_buff(dc : DataContainer) -> void:
	var _data = dc.data
	activated_buff_list[dc] = _data
	
	for m in _data.modifiers: #直接触发这颗子弹的所有modifier
		_apply_buff_effect(m)


func remove_buff(dc : DataContainer) -> void:
	activated_buff_list.erase(dc)


#内部函数 执行buff效果 
func _apply_buff_effect(modifier : BulletModifierData) -> void:
	match modifier.effect:
		"heal_player":
			#Player.instance.hp += 5
			print("触发弹药装填效果 ： 治疗玩家生命") #TODO 这里区分一下 触发的效果 
		
		"fire_enemy":
			print("触发弹药击中效果 ： 敌人被点燃")
		
		"criti_hit":
			print("触发弹药发射效果 ： 暴击几率增加")
		
		"buff_reload_speed":
			#Player.instance.apply_buff("reload_speed", 1.5, 3.0)
			print("触发弹药装填效果 ： 换弹速度提升")
		_:
			print("未找到效果 ： ", modifier.effect)
			return
