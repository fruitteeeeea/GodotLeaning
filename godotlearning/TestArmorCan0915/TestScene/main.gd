extends Node2D

@onready var armor_can_test: Node2D = $ArmorCanTest
@onready var work_shop_test: Node2D = $WorkShopTest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkShopServer.workshop_opened.connect(func() : armor_can_test.hide())
	WorkShopServer.workshop_closed.connect(func() : armor_can_test.show())
