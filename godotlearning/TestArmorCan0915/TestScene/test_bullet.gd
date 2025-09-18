extends BulletBase
class_name TestBullet

@onready var icon: Sprite2D = $Icon
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func change_pos(pos : Vector2): #位置转移到弹夹 
	global_position = pos 
