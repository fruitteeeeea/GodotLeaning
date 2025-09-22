extends Node2D

var file_path := "Test" #文件目录 #确保有这个文件夹
var file_name := "chik" #文件名

@onready var label: Label = $Label

var current_level := 1

func _ready() -> void:
	load_status("Test" ,"chik")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		current_level += 1
	if event.is_action_pressed("mouse_right"):
		current_level -= 1


func save_status(folder: String, file_name : String):
	var res = TestPlayerStatus.new()
	res.level = current_level
	
	var path := get_file_path(folder, file_name)
	var error = ResourceSaver.save(res, path)
	
	if error == OK:
		print("保存成功 -> ", path)
	else: 
		push_error("保存失败: %s" % error)


func load_status(folder, file_name) -> Resource:
	var path := get_file_path(folder, file_name)
	if ResourceLoader.exists(path):
		var res = ResourceLoader.load(path) as TestPlayerStatus
		
		print("读取成功 -> ", path)
		current_level = res.level
		return res
	else:
		push_error("资源不存在: %s" % path)
		return null


#输入文件夹路径 和文件名字 #返回文件路径
func get_file_path(folder: String, file_name : String) -> String:
	var path := "" 
	
	# 确保路径合法，自动补全 .tres
	if not file_name.ends_with(".tres"):
		file_name += ".tres"
	
	path = "user://%s/%s" % [folder, file_name] #使用 % 补全路径 #注意 在导出游戏之后 这里是 "user://"
	#print(OS.get_user_data_dir()) #这个可以获取文件在系统中的位置 
	return path


func _physics_process(delta: float) -> void:
	label.text = "level : " + str(current_level)


func _on_save_pressed() -> void:
	save_status("Test" ,"chik")


func _on_load_pressed() -> void:
	load_status("Test" ,"chik")
