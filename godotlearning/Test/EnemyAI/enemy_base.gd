extends CharacterBody2D

@onready var root: Node2D = $Root
@onready var bt_player: BTPlayer = $BTPlayer

var _moved_this_frame: bool = false
var _frames_since_facing_update: int = 0

@export var health := 3.0

func _physics_process(_delta: float) -> void:
	_post_physics_process.call_deferred()


func _post_physics_process() -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector2.ZERO, 0.5)
	_moved_this_frame = false


func move(p_velocity: Vector2) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true

## Update agent's facing in the velocity direction.
func update_facing() -> void:
	_frames_since_facing_update += 1
	if _frames_since_facing_update > 3:
		face_dir(velocity.x)

## Face specified direction.
func face_dir(dir: float) -> void:
	if dir > 0.0 and root.scale.x < 0.0:
		root.scale.x = 1.0;
		_frames_since_facing_update = 0
	if dir < 0.0 and root.scale.x > 0.0:
		root.scale.x = -1.0;
		_frames_since_facing_update = 0

## Returns 1.0 when agent is facing right.
## Returns -1.0 when agent is facing left.
func get_facing() -> float:
	return signf(root.scale.x)


## Is specified position inside the arena (not inside an obstacle)?
func is_good_position(p_position: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p_position
	params.collision_mask = 1 # Obstacle layer has value 1
	var collision := space_state.intersect_point(params)
	return collision.is_empty()


func take_damage():
	health -= 1.0
	if health <= 0:
		queue_free()


func flip():
	scale.x *= -1
	pass


func _on_hit_box_area_entered(area: Area2D) -> void:
	var hit_target = area.get_parent().get_parent()
	if hit_target.has_method("take_damage"):
		hit_target.take_damage()
