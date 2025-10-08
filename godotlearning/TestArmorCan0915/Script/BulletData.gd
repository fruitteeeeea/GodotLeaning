extends Resource
class_name BulletData

#子弹基础属性 
@export var base_damage: float = 10
@export var size: float = 1.0
@export var speed: float = 400

#子弹在弹药库中的信息
@export var pool_weight := 1.0
@export var pool_size := Vector2.ONE

#子弹的附魔属性（火属性 冰属性 
@export var enchantments: Array[BulletEnhanceMentData] = [] 

#子弹的额外机制（开火 装填 击中 击杀
@export var modifiers: Array[BulletModifierData] = [] 

#===标签展示相关===
@export var BulletName := "普通子弹"
@export_enum("装填", "开火", "击中", "击杀") var TriggerType := "装填"
@export var BulletDescription := "没有特殊效果。"

#根据 trigger 获取对应的 modifier   #需要大改 这里是直接触发对应效果的 
func get_modifiers(trigger_type: BulletModifierData.TriggerEvent) -> Array[BulletModifierData]:
	var list : Array[BulletModifierData] = []
	for m in modifiers:
		if m.trigger == trigger_type:
			list.append(m)
	return list

#获取子弹的所有元素反应 
func get_enchantments() -> Array[BulletEnhanceMentData]:
	var list : Array[BulletEnhanceMentData]
	for e in enchantments:
		list.append(e) #返回子弹附带的效果 
	return list

#Test 子弹测试 
@export_category("DebuggTest")
@export var color_list := [Color.RED, Color.BLUE, Color.YELLOW]
@export var color : Color = Color.WHITE
@export var description : String
@export var pool_index : int #子弹在弹仓和弹夹中的id
