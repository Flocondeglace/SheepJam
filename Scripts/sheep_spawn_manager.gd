extends Node

const SHEEP = preload("res://Scenes/sheep.tscn")

@export var sheeps_container: Node2D
@export var goal_pos_balloon : float = 100
@export var start_pos_balloon : float = -100
@export var goal_pos_walk : float = 100
@export var start_pos_walk : float = -100
@export var epsilon_pos : float = 1
@export var speed_balloon : float = 2
@export var colors_balloon : Array[Color] = []
@export var space_between_spawned_sheep : float = 20
@export var number_spawn_sheep_walking : float = 4
@export var number_spawn_sheep_flying : float = 3

@onready var spawning_position_walking_right: Marker2D = $SpawningPositionWalkingRight
@onready var goal_position_walking_right: Marker2D = $GoalPositionWalkingRight
@onready var spawning_position_walking_left: Marker2D = $SpawningPositionWalkingLeft
@onready var goal_position_walking_left: Marker2D = $GoalPositionWalkingLeft

@onready var spawning_position_flying: Marker2D = $Balloon/SpawningPositionFlying
@onready var goal_position_flying: Marker2D = $Balloon/GoalPositionFlying


@onready var balloon: StaticBody2D = $Balloon
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var marker_2d_left: Marker2D = $BalloonPosX/Marker2DLeft
@onready var marker_2d_right: Marker2D = $BalloonPosX/Marker2DRight
@onready var sprites: Node2D = $Balloon/Sprites
@onready var back_balloon_sprite: Sprite2D = $Balloon/Sprites/Back

var spawning_positions : Array[Node]
var sheep_in_spawning_area : Array[Sheep] = []
var sheeps_arrived : bool = false
var camera_left : bool = true
var using_balloon : bool = false

func _ready() -> void:
	# spawning_positions = spawning_positions_walking_sheep_container.get_children()
	sheep_walking_appear()


func _process(_delta: float) -> void:
	if sheeps_arrived && !check_still_sheep_in_spawn():
		camera_left = !camera_left
		if camera_left:
			camera_2d.swipe_left()
		else :
			camera_2d.swipe_right()
		var list_sprite = sprites.get_children()
		for sprite in list_sprite:
			sprite.flip_h = camera_left
			if camera_left:
				sprite.position.x -= sprite.get_rect().size.x/2
			else:
				sprite.position.x += sprite.get_rect().size.x/2
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
	if camera_left:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_walking_left.position, -1, true)
	else:
		spawn_sheeps(number_spawn_sheep_walking, spawning_position_walking_right.position, 1, true)
	

func balloon_appear():
	back_balloon_sprite.modulate = colors_balloon.pick_random()
	sheeps_arrived = false
	print("Balloon appear")
	if camera_left:
		balloon.position.x = marker_2d_left.position.x
	else:
		balloon.position.x = marker_2d_right.position.x
	balloon.position.y = camera_2d.get_screen_center_position().y + camera_2d.get_viewport_rect().size.y/2 - start_pos_balloon
	# Sheep appear
	spawn_sheeps(number_spawn_sheep_flying, spawning_position_flying.position)

func spawn_sheeps(number_sheep :int, spawn_position: Vector2, dir: int = 1, is_walking = false):
	sheep_in_spawning_area = []
	for i in range(number_sheep):
		var sheep = SHEEP.instantiate()
		sheep.position = spawn_position + dir*Vector2(i*space_between_spawned_sheep,0)
		
		print(sheep.position)
		sheeps_container.add_child(sheep)
		sheep_in_spawning_area.append(sheep)
		sheep.should_respawn.connect(_on_sheep_should_respawn)
		sheep.look_left(!camera_left)
		if is_walking:
			sheep.animation_player_sprite.play("Walking")


func move_balloon():
	var pos_cam : Vector2 = camera_2d.get_screen_center_position()
	var size_viewport : Vector2 = camera_2d.get_viewport_rect().size
	var goal_pos_balloon_global = pos_cam.y + size_viewport.y/2 - goal_pos_balloon
	if abs(goal_pos_balloon_global - balloon.position.y) < epsilon_pos:
		sheeps_arrived = true
		
	if sheeps_arrived:
		balloon.position.y = lerp(balloon.position.y, goal_pos_balloon_global, 0.1)
	else:
		balloon.position.y -= speed_balloon

func move_walking():
	if !sheeps_arrived:
		for s in sheep_in_spawning_area:
			if camera_left:
				s.force_position(s.position + Vector2(1,0))
			else:
				s.force_position(s.position + Vector2(-1,0))

func _on_sheep_should_respawn(sheep:Sheep):
	if sheeps_arrived:
		# print("Should respawn")
		for i in range(sheep_in_spawning_area.size()):
			if sheep_in_spawning_area[i] == sheep:
				if using_balloon:
					sheep.force_position(goal_position_flying.position - Vector2(i*space_between_spawned_sheep,0))
				else:
					if camera_left:
						sheep.force_position(goal_position_walking_left.position - Vector2(i*space_between_spawned_sheep,0))
					else:
						sheep.force_position(goal_position_walking_right.position + Vector2(i*space_between_spawned_sheep,0))
					
				
func _on_area_goal_pos_w_body_entered(body: Node2D) -> void:
	if body is Sheep:
		sheeps_arrived = true
		print("Arrived")
		for sheep in sheep_in_spawning_area:
			sheep.animation_player_sprite.play("Idle")
