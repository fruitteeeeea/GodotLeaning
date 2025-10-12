extends Node2D

var file_path := "Test" #文件目录 #确保有这个文件夹
var file_name := "chik" #文件名

@onready var label: Label = $Label

var current_level := 1

func _ready() -> void:
	load_level()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		current_level += 1
	if event.is_action_pressed("mouse_right"):
		current_level -= 1


func load_level() -> void:
	var res = FileHelper.load_status("Test" ,"chik") as TestPlayerStatus
	current_level = res.level

func save_level() -> void:
	var res = TestPlayerStatus.new()
	res.level = current_level
	FileHelper.save_status(res, "Test" ,"chik")


func _physics_process(delta: float) -> void:
	label.text = "level : " + str(current_level)


func _on_save_pressed() -> void:
	save_level()


func _on_load_pressed() -> void:
	load_level()
