extends Node

#@onready var ui = UIManager
#
#func start_workshop_flow():
	#show_bullet_set()
#
#func show_bullet_set():
	#ui.show_panel("bullet_set", {}, func(_result):
		#show_item_select())
#
#func show_item_select():
	#ui.show_panel("item_select", {"money": 1000}, func(item_result):
		#show_bullet_select(item_result))
#
#func show_bullet_select(item_result):
	#ui.show_panel("bullet_select", {"item": item_result}, func(bullet_result):
		#show_confirm(bullet_result))
#
#func show_confirm(bullet_result):
	#ui.show_panel("confirm", {"summary": bullet_result}, func(confirm_result):
		#if confirm_result["confirmed"]:
			#print("流程完成！")
		#else:
			#print("取消应用")
	#)
