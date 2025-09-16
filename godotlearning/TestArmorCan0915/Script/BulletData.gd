extends Resource
class_name BulletData

#子弹基础属性 
@export var base_damage: float = 10
@export var size: float = 1.0
@export var speed: float = 400

#子弹的附魔属性（火属性 冰属性 
@export var enchantments: Array[BulletEnhanceMentData] = []

#子弹的额外机制（开火 击中 击杀
@export var modifiers: Array[BulletModifierData] = [] 
