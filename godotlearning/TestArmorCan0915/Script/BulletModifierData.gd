extends Resource
class_name BulletModifierData

enum TriggerEvent { ON_RELOAD, ON_FIRE, ON_HIT, ON_KILL } #不同阶段触发的效果 
@export var trigger: TriggerEvent
@export var effect: String  # 例如 "heal_player", "spawn_bomb", "buff_speed"
@export var value: float = 0
