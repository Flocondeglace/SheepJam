extends Node

const SHEEP = preload("res://Scenes/sheep.tscn")

@export var sheeps_container: Node2D
@export var goal_pos_balloon : float = 100
@export var start_pos_balloon : float = -100
@export var epsilon_pos_balloon : float = 1
@export var speed_balloon : float = 2
@export var colors_balloon : Array[Color] = []

@onready var spawning_positions_container: Node2D = $Balloon/SpawningPositionsContainer
@onready var balloon: StaticBody2D = $Balloon
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var marker_2d_left: Marker2D = $BalloonPosX/Marker2DLeft
@onready var marker_2d_right: Marker2D = $BalloonPosX/Marker2DRight
@onready var sprites: Node2D = $Balloon/Sprites
@onready var back_balloon_sprite: Sprite2D = $Balloon/Sprites/Back

var spawning_positions : Array[Node]
var sheep_in_spawning_area : Array[Sheep] = []
var balloon_arrived : bool = false
var camera_left : bool = true

func _ready() -> void:
	spawning_positions = spawning_positions_container.get_children()
	balloon_appear()


func _process(delta: float) -> void:
	if balloon_arrived && !check_still_sheep_in_spawn():
		camera_left = !camera_left
		if camera_left:
			camera_2d.swipe_left()
		else :
			camera_2d.swipe_right()
		var list_sprite = sprites.get_children()
		for sprite in list_sprite:
			sprite.flip_h = camera_left
			var s: Sprite2D = sprite
			if camera_left:
				sprite.position.x -= sprite.get_rect().size.x/2
			else:
				sprite.position.x += sprite.get_rect().size.x/2
		
		balloon_appear()
	move_balloon()

func check_still_sheep_in_spawn():
	for sheep in sheep_in_spawning_area:
		if !sheep.have_collided:
			return true
	return false

func balloon_appear():
	back_balloon_sprite.modulate = colors_balloon.pick_random()
	balloon_arrived = false
	print("Balloon appear")
	if camera_left:
		balloon.position.x = marker_2d_left.position.x
	else:
		balloon.position.x = marker_2d_right.position.x
	balloon.position.y = camera_2d.get_screen_center_position().y + camera_2d.get_viewport_rect().size.y/2 - start_pos_balloon
	
	# Sheep appear
	sheep_in_spawning_area = []
	for pos_marker in spawning_positions:
		var sheep = SHEEP.instantiate()
		sheep.position = pos_marker.get_global_position()
		sheeps_container.add_child(sheep)
		sheep_in_spawning_area.append(sheep)
		sheep.should_respawn.connect(_on_sheep_should_respawn)
		sheep.look_left(!camera_left)

func move_balloon():
	var pos_cam : Vector2 = camera_2d.get_screen_center_position()
	var size_viewport : Vector2 = camera_2d.get_viewport_rect().size
	var goal_pos_balloon_global = pos_cam.y + size_viewport.y/2 - goal_pos_balloon
	if abs(goal_pos_balloon_global - balloon.position.y) < epsilon_pos_balloon:
		balloon_arrived = true
		
	if balloon_arrived:
		balloon.position.y = lerp(balloon.position.y, goal_pos_balloon_global, 0.1)
	else:
		balloon.position.y -= speed_balloon


func _on_sheep_should_respawn(sheep:Sheep):
	if balloon_arrived:
		print("Should respawn")
		for i in range(sheep_in_spawning_area.size()):
			if sheep_in_spawning_area[i] == sheep:
				sheep.force_position(spawning_positions[i].get_global_position())
			
