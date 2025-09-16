extends Resource
class_name BulletEnhanceMentData

enum ElementType { FIRE, ICE, LIGHTNING, POISON }
@export var type: ElementType
@export var extra_damage: float = 5
@export var on_hit_effect: String = "" # 例如 "burn", "slow"
