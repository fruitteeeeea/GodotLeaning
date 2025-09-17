extends Resource
class_name BulletData

#子弹基础属性 
@export var base_damage: float = 10
@export var size: float = 1.0
@export var speed: float = 400

#Test 子弹测试 
@export var color_list := [Color.RED, Color.BLUE, Color.YELLOW]
@export var color : Color = Color.WHITE

#子弹在弹药库中的信息
@export var pool_weight := 1.0
@export var pool_size := Vector2.ONE

#子弹的附魔属性（火属性 冰属性 
@export var enchantments: Array[BulletEnhanceMentData] = []

#子弹的额外机制（开火 击中 击杀
@export var modifiers: Array[BulletModifierData] = [] 
