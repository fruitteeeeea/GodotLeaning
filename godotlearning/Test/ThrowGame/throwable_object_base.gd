extends CharacterBody2D
class_name ThrowableObject

signal landed # 投掷结束并落地（可捡起）

@export var throw_speed: float = 700.0         # 默认投掷速度（像素/秒）
@export var bounce_factor: float = 0.8         # 每次碰撞对速度的衰减（1.0 完全弹回, <1 会损失能量）
@export var max_throw_distance: float = 400.0  # 投掷目标距离（像素）

@onready var ice_cbue_water: CPUParticles2D = $IceCbueWater

var decel_rate: float = 1.0 # 数值越大减速越快

var is_carried: bool = false
var is_thrown: bool = false
var _velocity: Vector2 = Vector2.ZERO

var _traveled: float = 0.0
var _last_global_pos: Vector2
var _carrier: Node = null

var current_scene : Node

func _ready() -> void:
	current_scene = get_tree().get_current_scene()
	_last_global_pos = global_position
	set_physics_process(true)


# 玩家调用：捡起物品
func pick_up(by: Node) -> void:
	#if is_thrown:
		#return
	is_carried = true
	_carrier = by
	# 将物品作为 carrier 的子节点（保持 local offset）
	var original_parent = get_parent()
	if original_parent:
		original_parent.remove_child(self)
	_carrier.add_child(self)
	position = Vector2(0, -10) # 默认偏移（可调整）
	velocity = Vector2.ZERO

# 将物品从 carrier 中放下（内部调用）
func _drop_to_world(at_pos: Vector2) -> void:
	if _carrier:
		_carrier.remove_child(self)
		current_scene.add_child(self) # 复位到当前场景根
	global_position = at_pos
	is_carried = false
	_carrier = null

# 玩家调用：投掷物品
# direction: Vector2 方向（世界坐标），distance: 想要的飞行总距离（像素），speed: 可选覆盖速度
func throw(direction: Vector2, distance: float, speed: float = -1.0) -> void:
	if not is_carried:
		# 允许地上再次投掷（可按需改）
		pass
	# 先放回世界（把 position 转为全局）
	
	var start_pos: Vector2
	if _carrier:
		start_pos = _carrier.global_position + position
	else:
		start_pos = global_position
	
	_drop_to_world(start_pos)
	is_thrown = true
	_traveled = 0.0
	_last_global_pos = global_position
	max_throw_distance = distance
	if speed > 0.0:
		throw_speed = speed
	velocity = direction.normalized() * throw_speed
	
	ice_cbue_water.emitting = true


func _physics_process(delta: float) -> void:
	if is_carried:
		# 当被携带时，自动跟随 carrier（position 已是 local）
		return

	if is_thrown:
		velocity = velocity.lerp(Vector2.ZERO, decel_rate * delta)
		
		# 每帧以 velocity 移动，检测碰撞并反射
		var move_vec = velocity * delta
		# move_and_collide 会在碰撞点停止并返回 collision info
		var col = move_and_collide(move_vec)
		# 记录距离（无论是否碰撞，都按尝试移动的长度累计）
		_traveled += move_vec.length()
		if col:
			var collider = col.get_collider()
			if collider is CharacterBody2D:
				return
			
			# col 是 KinematicCollision2D
			var normal = col.get_normal()
			# 反射速度并乘以能量保留系数
			velocity = velocity.bounce(normal) * bounce_factor
			# 如果速度非常小，直接停止
			#if velocity.length() < 5.0:
				#_end_throw()
				#return
		# 投掷到达目标距离后结束（也可改为按时间）
		if _traveled >= max_throw_distance:
			_end_throw()
	
		if velocity.length() < 5.0:
			_end_throw()


func _end_throw() -> void:
	is_thrown = false
	velocity = Vector2.ZERO
	_traveled = 0.0
	emit_signal("landed")
	
	ice_cbue_water.emitting = false
