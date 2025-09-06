extends Control

@onready var h_slider: HSlider = $HSlider
@onready var label: Label = $Label
@onready var label_2: Label = $Label2


# 定义属性，带 getter 和 setter
var health:
	set(v):
		health = clamp(v, 0, 100)
		update_ui()
		if health <= 10:
			is_low_health = true
		else :
			is_low_health = false
		
	get():
		print("尝试获取health")
		return health

var is_low_health: bool:
	set(v):
		is_low_health = v
		if is_low_health:
			print("低血量预警")
			label_2.visible = true
		else :
			label_2.visible = false
			print("wu")


func get_health() -> int:
	return health

func _ready():
	health = 80
	is_low_health = false

func update_ui():
	label.text = "Health: %d" % health

func _on_h_slider_value_changed(value: float) -> void:
	health = int(value)
