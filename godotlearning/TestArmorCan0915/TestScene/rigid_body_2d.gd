extends RigidBody2D

@onready var test_bullet: Node2D = $".."

@onready var icon: Sprite2D = $Icon
@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	var info = test_bullet.bullet_info
	
	modulate = info.color #变更颜色
	
	icon.scale *= info.pool_size
	collision_shape_2d.scale  *= info.pool_size
