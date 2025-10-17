extends Node2D

#这里应该只有一个按钮 就是打开工房。
@onready var open_work_shop: Button = $OpenWorkShop

func _ready() -> void:
	WorkShopServer.workshop_opened.connect(func(): open_work_shop.hide())
	WorkShopServer.workshop_closed.connect(func(): open_work_shop.show())


func _on_open_work_shop_pressed() -> void:
	WorkShopServer.open_workshop()
