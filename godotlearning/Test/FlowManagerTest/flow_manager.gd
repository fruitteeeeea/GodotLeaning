extends Node2D

signal state_changed(old_state, new_state)

const UI_SCENE = preload("res://Test/FlowManagerTest/ui_scene.tscn")
@onready var label: Label = $Label

var state_info := {
	GameState.PHASE01 : ["PHASE01", 1, func(): pass, func(): switch_to(GameState.PHASE02)],
	GameState.PHASE02 : ["PHASE02", 2, func(): switch_to(GameState.PHASE01), func(): switch_to(GameState.PHASE03)],
	GameState.PHASE03 : ["PHASE03", 2, func(): switch_to(GameState.PHASE02), func(): switch_to(GameState.PHASE04)],
	GameState.PHASE04 : ["PHASE04", 3, func(): switch_to(GameState.PHASE03), func(): pass],
}

enum GameState { PHASE00, PHASE01, PHASE02, PHASE03, PHASE04 }

var current_state : GameState = GameState.PHASE00
var current_scene : BasicUIScene

func _ready():
	switch_to(GameState.PHASE01)

func _process(delta: float) -> void:
	label.text = str(current_state)


func switch_to(new_state : GameState) -> void:
	if new_state == current_state:
		return
	
	var old_state = current_state
	current_state = new_state
	emit_signal("state_changed", old_state, new_state)

	# 卸载旧场景
	if current_scene:
		current_scene.outof_scene()

	# 加载新场景
	var new_scene = UI_SCENE.instantiate() as BasicUIScene
	add_child(new_scene)
	current_scene = new_scene

	var _text = state_info[new_state][0]
	var _type = state_info[new_state][1]
	current_scene.set_up_panel(_text, _type)
	
	var call01 = state_info[new_state][2] as Callable
	var call02 = state_info[new_state][3] as Callable
	#链接信号
	new_scene.pre_button_press.connect(call01)
	new_scene.nex_button_press.connect(call02)
