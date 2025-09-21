extends Node2D

@export var status := preload("res://Test/GodotSaveLearing/chik.tres")
@export var run_time_status := TestPlayerStatus.new()

@onready var label: Label = $Label



func _ready() -> void:
	#_load()
	load_status("Test/GodotSaveLearing" ,"chik")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		run_time_status.level += 1
	if event.is_action_pressed("mouse_right"):
		run_time_status.level -= 1


const save_location = "res://Test/GodotSaveLearing/chik.tres"
var status01 := TestPlayerStatus.new()

func _save():
	ResourceSaver.save(status01, save_location)


func _load():
	if FileAccess.file_exists(save_location):
		var res = ResourceLoader.load(save_location).duplicate(true) as TestPlayerStatus
		status01.level = res.level
		print(res.level)


func save_status(folder: String, file_name : String):
	
	
	var path := get_file_path(folder, file_name)
	var error = ResourceSaver.save(run_time_status, path)
	if error == OK:
		print("保存成功 -> ", path)
		print(run_time_status.level)
		status.level = run_time_status.level
		print(status.level)
	else: 
		push_error("保存失败: %s" % error)
	
	
	#var path := get_file_path(folder, file_name)
	#var resource = run_time_status.duplicate(true)
	#var error = ResourceSaver.save(resource, path) #输入需要保存的资源 以及路径 
	##status.level = run_time_status.level



func load_status(folder, file_name) -> Resource:
	var path := get_file_path(folder, file_name)
	if ResourceLoader.exists(path):
		#run_time_status = ResourceLoader.load(path).duplicate(true)
		run_time_status.level = ResourceLoader.load(path).duplicate(true).level
		return run_time_status
	else:
		push_error("资源不存在: %s" % path)
		return null


#输入文件夹路径 和文件名字 #返回文件路径
func get_file_path(folder: String, file_name : String) -> String:
	var path := "" 
	
	# 确保路径合法，自动补全 .tres
	if not file_name.ends_with(".tres"):
		file_name += ".tres"
	
	path = "res://%s/%s" % [folder, file_name] #使用 % 补全路径 #注意 在导出游戏之后 这里是 "user://"
	return path


func _physics_process(delta: float) -> void:
	label.text = "level : " + str(run_time_status.level)


func _on_save_pressed() -> void:
	#_save()
	save_status("Test/GodotSaveLearing" ,"chik")


func _on_load_pressed() -> void:
	#_load()
	load_status("Test/GodotSaveLearing" ,"chik")
