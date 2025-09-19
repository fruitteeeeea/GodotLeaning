extends Node2D

class DebugCircle:
	var pos: Vector2
	var radius: float
	var color: Color
	var time_left: float
	
	func _init(p: Vector2, r: float, c: Color, t: float):
		pos = p
		radius = r
		color = c
		time_left = t

var circles: Array[DebugCircle] = []

func _process(delta):
	# 更新存活时间
	for i in range(circles.size() - 1, -1, -1):
		circles[i].time_left -= delta
		if circles[i].time_left <= 0:
			circles.remove_at(i)
	queue_redraw()

func _draw():
	for c in circles:
		draw_circle(c.pos, c.radius, c.color)

# --- 对外接口 ---
func add_circle(pos: Vector2, radius: float = 5, color: Color = Color.RED, duration: float = 5.5):
	circles.append(DebugCircle.new(pos, radius, color, duration))
	queue_redraw()

func clear_circles():
	circles.clear()
	queue_redraw()
