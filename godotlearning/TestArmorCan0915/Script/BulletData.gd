extends Resource
class_name BulletData

#子弹基础属性 
@export var base_damage: float = 10
@export var size: float = 1.0
@export var speed: float = 400

#子弹的额外机制（开火 装填 击中 击杀
@export var modifiers: Array[BulletModifierData] = [] 

#充能类型 
enum ChargeEvent { ON_LOAD, ON_FIRE, ON_HITT, ON_KILL } #不同阶段触发的充能 
@export var charger: ChargeEvent = ChargeEvent.ON_FIRE #默认是开火充能
@export_range(0.0, 1.0, .05) var charger_nb := .3 

#===标签展示相关===
@export var BulletName := "普通子弹" 
@export_enum("装填", "开火", "击中", "击杀") var TriggerType := "装填" 
@export var BulletDescription := "没有特殊效果。"

#Test 子弹测试 
@export_category("DebuggTest")
@export var color_list := [Color.RED, Color.BLUE, Color.YELLOW]
@export var color : Color = Color.WHITE
@export var description : String
@export var pool_index : int #子弹在弹仓和弹夹中的id
