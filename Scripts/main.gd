extends Node2D

@onready var animation_transition: AnimationPlayer = $Transition/AnimationPlayer

@onready var sheeps_container: Node2D = $SheepsContainer

const sheep_scene = preload("res://Scenes/sheep.tscn") # Ensure path is correct

var current_highest_sheep_y = 9999
var highest_sheep_y = 9999

var sheep_count = 0

@onready var camera_2d: Camera2D = $Camera2D
@export var camera_freeze_height: float = 100
var initial_camera_y = 0
var ground_y = 0
var max_zoom=0.4

var highest_score = 0
var progress_percentage = 0
@export var max_height = -2000
@export var score_to_meters: float = 100
@onready var score: Label = $CanvasLayer/Score
@onready var ground_marker: Marker2D = $GroundMarker

@export var loosing_height: float = 100


func _ready():
	initial_camera_y = camera_2d.position.y
	ground_y = ground_marker.position.y
	animation_transition.play("transition")


func _process(_delta):
	current_highest_sheep_y = sheeps_container.get_current_highest_sheep_y()
	if current_highest_sheep_y < highest_sheep_y:
		highest_sheep_y = current_highest_sheep_y
	
	#if current_highest_sheep_y+120 < initial_camera_y:
		
		#if current_highest_sheep_y+120 < initial_camera_y:
			
		#	
		#else:
		#	camera_2d.position.y = lerp(camera_2d.position.y, initial_camera_y, 0.1)
		if highest_sheep_y != 9999:
			sheeps_container.freeze_sheep_under_height(current_highest_sheep_y+camera_freeze_height)
			update_score()
			update_camera_zoom_and_y_pos()
			update_progress_percentage()

func update_progress_percentage():
	var progress_distance = current_highest_sheep_y - ground_y
	progress_percentage = progress_distance / max_height


func update_camera_zoom_and_y_pos():
	var center_pos = (current_highest_sheep_y - 300 + ground_y + 20) / 2
	var camera_view_size = camera_2d.get_viewport_rect().size

	#calculate the zoom to fit the camera view between up_pos and down_pos
	# we know that camera_real_size = camera_view_size / camera_zoom 
	
	var zoom = camera_view_size.y / (ground_y+ 20-(current_highest_sheep_y-300))

	if zoom < 1 and zoom > max_zoom :

		#set camera y pos
		if center_pos > initial_camera_y:
			center_pos = initial_camera_y
		camera_2d.position.y = center_pos

		#set camera zoom
		if zoom < 1:
			camera_2d.zoom = Vector2(zoom,zoom)
	# D
	elif zoom < 1 :
		zoom = max_zoom
		camera_2d.zoom = Vector2(zoom,zoom) 
		camera_2d.position.y = lerp(camera_2d.position.y, current_highest_sheep_y-250, 0.1)




func update_score():
	var score_meters = 0
	if highest_sheep_y == 9999:
		score_meters = 0
	else:
		score_meters = ground_y - highest_sheep_y
	
	if score_meters > highest_score:
		highest_score = score_meters
		score.text = str("%0.2f" % (highest_score / score_to_meters)," m")
	
	if is_loosing():
		score.text = "You are losing"
		sheeps_container.free_all_sheep()


#Test if the player is loosing by testing if the highest sheep is lower than highest_sheep_y + loosing_height
func is_loosing():
	if current_highest_sheep_y > highest_sheep_y + loosing_height:
		return true
	else:
		return false

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			spawn_sheep(get_global_mouse_position())

func spawn_sheep(spawn_position: Vector2):
	sheep_count += 1
	if sheep_scene:
		var sheep_instance = sheep_scene.instantiate()
		sheeps_container.add_child(sheep_instance) # Add to scene tree BEFORE setting global_position for RigidBody2D
		sheep_instance.global_position = spawn_position
		print("Spawned sheep at: ", spawn_position)
	else:
		printerr("Sheep scene not loaded!")
