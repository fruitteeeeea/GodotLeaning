extends Node
class_name DungeonUtils
# 存储一些简单的工具 

#寻找邻居 
func _find_neighbors(pos: Vector2i, grid : Dictionary) -> Array[int]:
	var ids : Array[int] = []
	var offsets := {
		Vector2i(0,-1): 1,  # N
		Vector2i(1,0): 2,   # E
		Vector2i(0,1): 4,   # S
		Vector2i(-1,0): 8,  # W
	}
	for off in offsets.keys():
		var np = pos + off
		if grid.has(np): 
			ids.append(grid[np])
	return ids
