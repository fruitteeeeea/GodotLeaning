extends Player
class_name TopdownPlayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var input := Vector2.ZERO
var current_dir : Vector2

@export var friction  := 800
@export var accel  := 2400
@export var max_speed  := 150


func _physics_process(delta: float) -> void:
	
	if can_control:
		player_movement(delta)


func get_input():
	input.x  = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y  = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()


func player_movement(delta):
	input = get_input()
	
	if input == Vector2.ZERO:
		
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else :
			velocity = Vector2.ZERO
		animation_player.play("RESET")
		
	else :
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
		
		current_dir = input
		animation_player.play("01")
	
	move_and_slide()


func player_dash(delta):
	pass
