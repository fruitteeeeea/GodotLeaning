extends HBoxContainer

@export var status_manager : StatusManager

@export var effect_and_icon := {}

func _ready() -> void:
	if status_manager:
		status_manager.status_added.connect(add_status_icon)
		status_manager.status_removed.connect(remove_status_icon)

 
func add_status_icon(status : StatusEffect, stacks : int) -> void:
	if status is ElementalEffect: #区分一下 如果有这个图标的话 直接修改
		var label : Label

		if status in effect_and_icon:
			label = effect_and_icon[status]
		else :
			label = Label.new()
			add_child(label)
			effect_and_icon[status] = label
		
		label.text = status.status_effect_icon + "X" + str(stacks)


func remove_status_icon(status : StatusEffect) -> void:
	if effect_and_icon.has(status):
		var label = effect_and_icon[status] as Label
		effect_and_icon.erase(status)
		label.queue_free()
