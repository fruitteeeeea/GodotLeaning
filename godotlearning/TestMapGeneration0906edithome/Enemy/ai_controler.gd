extends Node2D
class_name AIControler
#这个节点一般作为敌人BTPlayer的父级 可以控制BTPlayer

signal StartStun
signal EndStun(restar_bt : bool)

@export var stun_time := 0.0
@export var stun_color : Color = Color.GRAY

var _was_stunned: bool = false   # 上一帧是否眩晕



func _ready() -> void:
	StartStun.connect(_on_start_stun)
	EndStun.connect(_on_end_stun)

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


#搜索全局get_stun 使用了这个方法的地方 确保路径正确 
#var AIC = target.get_node_or_null("VisibleOnScreenEnabler2D/AIControler") as AIControler
#if AIC:
	#AIC.get_stun()

func get_stun(t := 1.0): 
	StartStun.emit()
	stun_time = t


func _on_start_stun() -> void:
	$"../../Sprite2D".modulate = stun_color
	$BTPlayer.active = false
	$"../../AnimationPlayer".pause()


func _on_end_stun(restar_bt: bool) -> void:
	$"../../Sprite2D".modulate = Color(1, 1, 1, 1)
	$BTPlayer.active = true
	$"../../AnimationPlayer".play()
	if restar_bt:
		$BTPlayer.restart()
