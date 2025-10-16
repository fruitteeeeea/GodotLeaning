extends Control

const CONFIRMATION_PANEL = preload("res://TestArmorCan0915/UI/confirmation_panel.tscn")

#example 直接召唤就行
#var panel = PanelServer.show_confirmation("01", "02", func(): print("01"), func(): print("02"))
#delete_panel.connect(panel._on_cancel_pressed)

# 创建确认框
func show_confirmation(text1: String, text2: String, on_confirm: Callable, on_cancel: Callable) -> ConfirmationPanel:
	var panel := CONFIRMATION_PANEL.instantiate() as ConfirmationPanel
	add_child(panel)
	panel.setup(text1, text2)
	
	if on_confirm:
		panel.confirmed.connect(on_confirm)
	if on_cancel:
		panel.canceled.connect(on_cancel)
	
	return panel
