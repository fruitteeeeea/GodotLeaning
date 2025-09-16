extends Node2D
class_name Weapon

@export var bullet_pool: BulletPool
@export var magazine: Magazine

func reload():
	magazine.reload(bullet_pool)

func fire():
	if magazine.bullets.is_empty():
		reload()
		return
#
	#var bullet = magazine.bullets.pop_front() #发射子弹函数 发射弹夹最前面的子弹 
	#var bullet_scene = preload("res://Bullet.tscn").instantiate()
	#bullet_scene.data = bullet
	#get_tree().current_scene.add_child(bullet_scene)
