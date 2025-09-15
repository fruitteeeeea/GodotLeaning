extends Enemy

signal StartStun
signal EndStun(restar_bt : bool)

@export var stun_time := 0.0
@export var stun_color : Color = Color.GRAY

var _was_stunned: bool = false   # 上一帧是否眩晕


func _physics_process(delta: float) -> void:
	check_stun(delta)


func check_stun(delta: float): 
	# 眩晕时间递减
	if stun_time > 0:
		stun_time -= delta
		if stun_time < 0:
			stun_time = 0
	
	var is_stunned := stun_time > 0
	# 边缘检测
	#if not _was_stunned and is_stunned:
		#_on_enter_stun()   # 本帧刚进入眩晕
	if _was_stunned and not is_stunned:
		EndStun.emit(false)    # 本帧刚退出眩晕

	# 更新上一帧状态
	_was_stunned = is_stunned


func get_stun(t := 1.0):
	StartStun.emit()
	stun_time = t


func _on_start_stun() -> void:
	$Sprite2D.modulate = stun_color
	bt_player.active = false
	animation_player.pause()


func _on_end_stun(restar_bt: bool) -> void:
	$Sprite2D.modulate = Color(1, 1, 1, 1)
	bt_player.active = true
	animation_player.play()
	if restar_bt:
		bt_player.restart()
