extends Node2D

const TEST_BULLET = preload("res://TestArmorCan0915/TestScene/test_bullet.tscn")


@export var bullet_pool := []
@export var magazine := []

@export var pool_size := 20
@export var magazine_size := 5

var is_locked := false

func _ready() -> void:
	rebuilt_bullet_pool()


func rebuilt_bullet_pool():
	if is_locked:
		return
	
	is_locked = true
	remove_bullet()
	for i in range(pool_size):
		add_bullet()
		await get_tree().create_timer(.1).timeout
	
	is_locked = false


func built_random_bullet_info() -> BulletData:
	var bullet = BulletData.new()
	
	bullet.color = bullet.color_list[randi_range(0, 2)]
	var sizex = randi_range(1, 2)
	var sizey = randi_range(1, 3)
	
	bullet.pool_size = Vector2(sizex, sizey)
	
	print(bullet.color)
	return bullet


func add_bullet():
	var info = built_random_bullet_info()
	
	var bullet = TEST_BULLET.instantiate()
	
	bullet.bullet_info = info
	
	bullet.global_position = Vector2.ONE * randf() * 5
	add_child(bullet)
	
	bullet_pool.append(bullet)


func remove_bullet():
	for i in bullet_pool:
		i.queue_free()
	
	for i in magazine:
		i.queue_free()
	
	bullet_pool.clear()
	magazine.clear()


func reload():
	if is_locked or bullet_pool.size() < magazine_size:
		return
	
	is_locked = true
	for i in range(magazine_size):
		
		var bullet = bullet_pool.pick_random()
		
		bullet_pool.erase(bullet)
		magazine.append(bullet)
		
		bullet.modulate.a *= .5
		
		await get_tree().create_timer(.1).timeout
		
	
	is_locked = false


func fire():
	if is_locked or magazine.size() <= 0:
		return
	
	is_locked = true
	var bullet = magazine.pick_random()
	magazine.erase(bullet)
	bullet.queue_free()
		
	is_locked = false
	pass
