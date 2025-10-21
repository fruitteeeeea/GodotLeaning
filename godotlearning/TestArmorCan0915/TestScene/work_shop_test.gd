extends Node2D

#这里应该只有一个按钮 就是打开工房。
@onready var open_work_shop: Button = $OpenWorkShop

func _ready() -> void:
	WorkShopServerV2.workshop_opened.connect(func(): open_work_shop.hide())
	WorkShopServerV2.workshop_closed.connect(func(): open_work_shop.show())


func _on_open_work_shop_pressed() -> void:
	WorkShopServerV2.open_workshop()
