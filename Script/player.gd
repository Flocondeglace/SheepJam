extends Node2D

var holding_sheep : Sheep2 = null
var mouse_positions : Array[Vector2] = []

@export var sheeps_container: Node2D
@export var throwing_force : float = 1.0
@export var max_force : float = 1000
@export var number_mouse_positions_considered : int = 10

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	if holding_sheep:
		PhysicsServer2D.body_set_state(
			holding_sheep.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			Transform2D.IDENTITY.translated(mouse_pos)
		)
		mouse_positions.append(mouse_pos)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		holding_sheep = select_sheep()
		if holding_sheep:
			mouse_positions = []
	if holding_sheep:
		if Input.is_action_just_released("click"):
			launch_sheep()
			

func select_sheep() -> Node2D:
	var sheeps = sheeps_container.get_children()
	for sheep : Sheep2 in sheeps:
		if sheep.is_under_mouse():
			return sheep
	return null

func mean_speed(a : Array[Vector2]) -> Vector2:
	var sx = 0
	var sy = 0
	for i in range(a.size() - 1):
		sx+=a[i+1].x - a[i].x
		sy+=a[i+1].y - a[i].y
	sx /= a.size() 
	sy /= a.size()
	return Vector2(sx,sy)

func clip_vector2(vec: Vector2, minv: Vector2, maxv: Vector2) -> Vector2:
	return Vector2(
		clamp(vec.x, minv.x, maxv.x),
		clamp(vec.y, minv.y, maxv.y)
		)

func launch_sheep():
	if mouse_positions.size() > number_mouse_positions_considered:
		var mouse_positions_to_consider : Array[Vector2] = mouse_positions.slice(-10, mouse_positions.size()-1)
		var direction: Vector2 = mean_speed(mouse_positions_to_consider)
		var direction_2: Vector2 = Vector2(sign(direction.x)*direction.x**2, sign(direction.y)*direction.y**2)
		holding_sheep.linear_velocity = Vector2.ZERO
		holding_sheep.angular_velocity = 0.0
		var force : Vector2 = clip_vector2(direction_2*throwing_force, Vector2(-max_force, -max_force), Vector2(max_force, max_force))
		print(force)
		holding_sheep.move(force)
	holding_sheep = null


func _on_throwing_zone_mouse_exited() -> void:
	if holding_sheep:
		launch_sheep()
