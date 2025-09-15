extends Line2D
class_name Trails
 
var queue : Array
@export var MAX_LENGTH : int = 50.0
 
@export var active_trail := false

func _process(_delta):
	if !active_trail:
		clear_points()
		return
	
	var pos = _get_position()

	queue.push_front(pos)
 
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
 
	clear_points()

	for point in queue:
		add_point(point)
 
func _get_position():
	return get_global_mouse_position()
