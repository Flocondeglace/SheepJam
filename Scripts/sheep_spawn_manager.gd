extends Node

const SHEEP = preload("res://Scenes/sheep.tscn")

@export var sheeps_container: Node2D
@export var goal_pos_balloon : float = 0.1
@export var start_pos_balloon : float = 200
@export var epsilon_pos : float = 50
@export var speed_balloon : float = 2
@export var speed_walking_sheep : float = 2
@export var colors_balloon : Array[Color] = []
@export var space_between_spawned_sheep : float = 20
@export var number_spawn_sheep_walking : int = 4
@export var number_spawn_sheep_flying : int = 3
@export var space_border_balloon : float = 20
@export var proba_big_sheep : float = 0

@onready var spawning_position_walking_right: Marker2D = $SpawningPositionWalkingRight
@onready var goal_position_walking_right: Marker2D = $GoalPositionWalkingRight
@onready var spawning_position_walking_left: Marker2D = $SpawningPositionWalkingLeft
@onready var goal_position_walking_left: Marker2D = $GoalPositionWalkingLeft

@onready var spawning_position_flying_left: Marker2D = $Balloon/SpawningPositionFlyingLeft
@onready var spawning_position_flying_right: Marker2D = $Balloon/SpawningPositionFlyingRight

# @onready var spawning_position_flying: Marker2D = $Balloon/SpawningPositionFlying

@onready var balloon: StaticBody2D = $Balloon
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var game : Node2D = $".."
@onready var marker_2d_left: Marker2D = $BalloonPosX/Marker2DLeft
@onready var marker_2d_right: Marker2D = $BalloonPosX/Marker2DRight
@onready var sprites: Node2D = $Balloon/Sprites
@onready var back_balloon_sprite: Sprite2D = $Balloon/Sprites/Back
@onready var balloon_disappear: BalloonDisappear = $BalloonDisappear

# var spawning_positions : Array[Node]
var sheep_in_spawning_area : Array[Sheep] = []
var sheeps_arrived : bool = true
var is_spawning_left : bool = false
var using_balloon : bool = false
var respawning_position : Vector2
var main
var color_balloon


func _process(_delta: float) -> void:
	if !using_balloon:
		if camera_2d.position.y < -200 :
			using_balloon = true
	
	if sheeps_arrived && !check_still_sheep_in_spawn():
		is_spawning_left = !is_spawning_left
		if using_balloon:
			make_balloon_disappear()
			balloon_appear()
		else:
			sheep_walking_appear()
	
	if using_balloon:
		move_balloon()
	else:
		move_walking()
	

func check_still_sheep_in_spawn():
	for sheep in sheep_in_spawning_area:
		if !sheep.have_collided:
			return true
	return false

func sheep_walking_appear():
	sheeps_arrived = false
	if is_spawning_left:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_walking_left.position, -1, true)
	else:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_walking_right.position, 1, true)

func make_balloon_disappear():
	if color_balloon:
		balloon_disappear.self_modulate = color_balloon
		balloon_disappear.position = balloon.position
		balloon_disappear.go_away(speed_balloon)

func balloon_appear():
	color_balloon = colors_balloon.pick_random()
	back_balloon_sprite.modulate = color_balloon
	sheeps_arrived = false
	if is_spawning_left:
		balloon.position.x = camera_2d.position.x - camera_2d.get_viewport_rect().size.x*space_border_balloon
	else:
		balloon.position.x = camera_2d.position.x + camera_2d.get_viewport_rect().size.x*space_border_balloon

	balloon.position.y = camera_2d.position.y - camera_2d.get_viewport_rect().size.y/2 - start_pos_balloon
	# Sheep appear
	if is_spawning_left:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_flying_left.position + balloon.position, -1, true)
	else:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_flying_right.position + balloon.position, 1, true)
	

func spawn_sheeps(number_sheep :int, spawn_position: Vector2, dir: int = 1, is_walking = false):
	sheep_in_spawning_area = []
	var big_sheep = false
	if randf() < proba_big_sheep and game.progress_percentage > 0.15:
		big_sheep = true
		number_sheep = 1
	
	for i in range(number_sheep):
		var sheep = SHEEP.instantiate()
		sheep.position = spawn_position + dir*Vector2(i*space_between_spawned_sheep,0) + Vector2(0,-30)
		if big_sheep:
			sheep.is_big_sheep = true
			sheep.position.y += -25
			sheep.position.x += dir*50
		sheeps_container.add_child(sheep)
		sheep_in_spawning_area.append(sheep)
		sheep.should_respawn.connect(_on_sheep_should_respawn)
		sheep.look_left(!is_spawning_left)
		if is_walking:
			sheep.animation_player_sprite.play("Walking")
		


func move_balloon():
	var pos_cam : Vector2 = camera_2d.get_screen_center_position()
	var size_viewport : Vector2 = camera_2d.get_viewport_rect().size
	var goal_pos_balloon_global = pos_cam.y - size_viewport.y/2 + goal_pos_balloon
	if !sheeps_arrived:
		if abs(goal_pos_balloon_global - balloon.position.y) < epsilon_pos:
			sheeps_arrived = true
			for sheep in sheep_in_spawning_area:
				sheep.on_arrived()
		
	if sheeps_arrived:
		balloon.position.y = lerp(balloon.position.y, goal_pos_balloon_global, 0.1)
	else:
		balloon.position.y += speed_balloon

func move_walking():
	if !sheeps_arrived:
		for s in sheep_in_spawning_area:
			if is_spawning_left:
				s.force_position(s.position + Vector2(speed_walking_sheep,0))
			else:
				s.force_position(s.position + Vector2(-speed_walking_sheep,0))

func _on_sheep_should_respawn(sheep:Sheep):
	if sheeps_arrived:
		# print("Should respawn")
		for i in range(sheep_in_spawning_area.size()):
			if sheep_in_spawning_area[i] == sheep:
				#desactive collision shape
				var dir = 1
				var spawning_position_flying = spawning_position_flying_right
				if is_spawning_left:
					dir = -1
					spawning_position_flying = spawning_position_flying_left
				if using_balloon:
					sheep.force_position(spawning_position_flying.position + balloon.position + dir*Vector2(i*space_between_spawned_sheep,0))
					sheep.on_inside_throwing_zone()
				else:
					sheep.force_position(respawning_position + dir*Vector2(i*space_between_spawned_sheep,0))
					sheep.on_inside_throwing_zone()
					
				


func _on_area_goal_pos_w_area_entered_right(area: Area2D) -> void:
	if area.is_in_group("outside"):
		var body = area.get_parent()
		if !is_spawning_left:
			for s in sheep_in_spawning_area:
				if s == body :
					sheeps_arrived = true
					respawning_position = body.position
					for sheep in sheep_in_spawning_area:
						sheep.on_arrived()
					return

func _on_area_goal_pos_w_area_entered_left(area: Area2D) -> void:
	if area.is_in_group("outside"):
		if is_spawning_left:
			var body = area.get_parent()
			for s in sheep_in_spawning_area:
				if s == body :
					sheeps_arrived = true
					respawning_position = body.position
					for sheep in sheep_in_spawning_area:
						sheep.on_arrived()
					return
