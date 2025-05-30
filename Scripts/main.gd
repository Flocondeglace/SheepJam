extends Node2D

@onready var sheeps_container: Node2D = $SheepsContainer

const sheep_scene = preload("res://Scenes/sheep.tscn") # Ensure path is correct

var current_highest_sheep_y = 9999
var highest_sheep_y = 9999

var sheep_count = 0

@onready var camera_2d: Camera2D = $Camera2D
@export var camera_freeze_height: float = 100
var initial_camera_y = 0

var highest_score = 0
@export var score_to_meters: float = 100
@onready var score: Label = $Score
@onready var ground_marker: Marker2D = $GroundMarker

@export var loosing_height: float = 100

func _ready():
	initial_camera_y = camera_2d.position.y


func _process(delta):
	if sheep_count > 0:
		current_highest_sheep_y = sheeps_container.get_current_highest_sheep_y()
		if current_highest_sheep_y < highest_sheep_y:
			highest_sheep_y = current_highest_sheep_y
		
		if current_highest_sheep_y < initial_camera_y:
			
			camera_2d.position.y = lerp(camera_2d.position.y, current_highest_sheep_y, 0.1)
		else:
			camera_2d.position.y = lerp(camera_2d.position.y, initial_camera_y, 0.1)
		
		sheeps_container.freeze_sheep_under_height(camera_2d.position.y+camera_freeze_height)

		update_score()

func update_score():
	var score_meters = 0
	if highest_sheep_y == 9999:
		score_meters = 0
	else:
		score_meters = ground_marker.position.y - highest_sheep_y
	
	if score_meters > highest_score:
		highest_score = score_meters
		score.text = str(highest_score / score_to_meters)+" m"
	
	if is_loosing():
		score.text = "You are loosing"


#Test if the player is loosing by testing if the highest sheep is lower than highest_sheep_y + loosing_height
func is_loosing():
	print("The highest sheep is at ", current_highest_sheep_y, " and the highest score is ", highest_sheep_y, " and the loosing height is ", loosing_height+highest_sheep_y)
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
