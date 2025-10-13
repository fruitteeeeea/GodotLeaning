extends Node

#输入需要保存的资源 、文件夹 、文件名
func save_status(resource : Resource, folder: String, file_name : String):
	var path := get_file_path(folder, file_name)
	var error = ResourceSaver.save(resource, path)
	
	if error == OK:
		print("保存成功 -> ", path)
	else: 
		push_error("保存失败: %s" % error)

#根据文件夹 、文件名获取资源
func load_status(folder, file_name) -> Resource:
	var path := get_file_path(folder, file_name)
	if ResourceLoader.exists(path):
		var res = ResourceLoader.load(path) as Resource
		
		print("读取成功 -> ", path)
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
	
	# 打开 user:// 根目录
	var dir := DirAccess.open("user://")
	
	# 如果指定的 folder 不存在，则创建它（支持多级目录）
	if not dir.dir_exists(folder):
		var err := dir.make_dir_recursive(folder)
		if err != OK:
			push_error("创建文件夹失败: %s (错误码: %d)" % [folder, err])
	
	path = "user://%s/%s" % [folder, file_name] #使用 % 补全路径 #注意 在导出游戏之后 这里是 "user://"
	#print(OS.get_user_data_dir()) #这个可以获取文件在系统中的位置 
	return path
