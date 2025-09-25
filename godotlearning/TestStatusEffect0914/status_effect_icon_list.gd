extends HBoxContainer

@export var status_manager : StatusManager

@export var effect_and_icon := {}

func _ready() -> void:
	if status_manager:
		status_manager.status_added.connect(add_status_icon)
		status_manager.status_removed.connect(remove_status_icon)

 
func add_status_icon(status : StatusEffect) -> void:
	if status is ElementalEffect:
		var label = Label.new()
		label.text = status.status_effect_icon
		call_deferred("add_child", label)
		effect_and_icon[status] = label
	
	print("添加了一个异常状态 %")


func remove_status_icon(status : StatusEffect) -> void:
	if effect_and_icon.has(status):
		var label = effect_and_icon[status] as Label
		effect_and_icon.erase(status)
		label.queue_free()
