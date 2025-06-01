extends Node2D

var holding_sheep : Sheep = null
var mouse_positions : Array[Vector2] = []

@export var sheeps_container: Node2D
@export var throwing_force : float = 20.0
@export var max_force : float = 500
@export var number_mouse_positions_considered : int = 10

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	if holding_sheep:
		var pos_to_mouse= lerp(holding_sheep.position, mouse_pos, 0.1)
		PhysicsServer2D.body_set_state(
			holding_sheep.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			Transform2D.IDENTITY.translated(pos_to_mouse)
		)
		mouse_positions.append(mouse_pos)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") and holding_sheep == null:
		holding_sheep = select_sheep()
		if holding_sheep:
			mouse_positions = []
	if holding_sheep:
		if Input.is_action_just_released("click"):
			print("Releasing sheep due to click release")
			launch_sheep()
			

func select_sheep() -> Node2D:
	var sheeps = sheeps_container.get_children()
	for sheep : Sheep in sheeps:
		print(sheep,sheep.is_under_mouse(),not sheep.can_be_glued)
		if sheep.is_under_mouse() and not sheep.can_be_glued and sheep.is_in_an_area:
			sheep.start_player_holding()
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
		var force : Vector2 = clip_vector2(direction_2*throwing_force, Vector2(-max_force, -max_force), Vector2(max_force, max_force))
		holding_sheep.launch(force)
	holding_sheep = null



func _on_throwing_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("outside") :
		area.get_parent().on_inside_throwing_zone()


func _on_throwing_zone_area_exited(area: Area2D) -> void:
	if area.is_in_group("outside") :
		area.get_parent().on_outside_throwing_zone()
		if holding_sheep:
			print("Launching sheep due to mouse exited the throwing zone")
			launch_sheep()
