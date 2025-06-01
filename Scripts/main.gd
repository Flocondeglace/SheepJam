extends Node2D

@onready var animation_transition: AnimationPlayer = $CanvasLayer/Transition/AnimationPlayer

@onready var sheeps_container: Node2D = $SheepsContainer

const sheep_scene = preload("res://Scenes/sheep.tscn") # Ensure path is correct

var current_highest_sheep_y = 9999
var highest_sheep_y = 9999

var sheep_count = 0
var end_cinematic_sheep_count = 0

@onready var camera_2d: Camera2D = $Camera2D
@export var camera_freeze_height: float = 100
@export var camera_height_margin: float = 300
var initial_camera_y = 0
var ground_y = 0
var max_zoom=0.4

var highest_score = 0
var progress_percentage = 0
@export var max_height = -2000
@export var final_score_meters: float = 1000
@onready var score: Label = $CanvasLayer/Score
@onready var ground_marker: Marker2D = $GroundMarker
var have_loosed = false
var has_reached_end = false

@onready var dialogue_manager: Control = $DialogueManager
var has_game_ended = false
var end_cinematic_playing = false

@export var loosing_height: float = 100

@onready var count_sheep_end: Label = $CanvasLayer/CountSheepEnd

@export var is_debug_mode = false

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
	if has_reached_end :
		progress_percentage = 1
		return
	var progress_distance = current_highest_sheep_y - ground_y
	progress_percentage = progress_distance / max_height
	progress_percentage = clamp(progress_percentage, 0, 1)



func update_camera_zoom_and_y_pos():
	if end_cinematic_playing:
		return
		
	if progress_percentage >= 1 and not has_game_ended:
		has_reached_end = true
		if camera_2d.zoom.x < 0.99:
			camera_2d.zoom = lerp(camera_2d.zoom, Vector2(1,1), 0.1)
			camera_2d.position.y = lerp(camera_2d.position.y, -3280.0, 0.1)
		else:
			end_game()
		return

	var center_pos = (current_highest_sheep_y - camera_height_margin + ground_y + 20) / 2
	var camera_view_size = camera_2d.get_viewport_rect().size

	#calculate the zoom to fit the camera view between up_pos and down_pos
	# we know that camera_real_size = camera_view_size / camera_zoom 
	
	var zoom = camera_view_size.y / (ground_y+ 20-(current_highest_sheep_y-camera_height_margin))

	if zoom < 1 and zoom > max_zoom :

		#set camera y pos
		if center_pos > initial_camera_y:
			center_pos = initial_camera_y
		camera_2d.position.y = lerp(camera_2d.position.y, center_pos, 0.1)

		#set camera zoom
		if zoom < 1:
			camera_2d.zoom = lerp(camera_2d.zoom, Vector2(zoom,zoom), 0.1)
	# D
	elif zoom < 1 and progress_percentage < 1 :
		zoom = max_zoom
		camera_2d.zoom = lerp(camera_2d.zoom, Vector2(zoom,zoom), 0.1)
		camera_2d.position.y = lerp(camera_2d.position.y, current_highest_sheep_y+camera_height_margin, 0.1)



func update_score():
	if have_loosed or has_reached_end:
		return
	var score_meters = 0
	if highest_sheep_y == 9999:
		score_meters = 0
	else:
		score_meters = ground_y - highest_sheep_y
	
	if score_meters > highest_score:
		highest_score = score_meters
		#exponential function to convert progress percentage to meters
		var score_progress_to_meters = progress_percentage**2 * final_score_meters 
		score.text = str("%d" % (score_progress_to_meters)," m")
	
	if is_loosing():
		score.text = "Your tower has fallen \n Sheeps are on the ground \n But they will try again \n You reached " + str(int(highest_score)) + " meters \n Right click to restart"
		sheeps_container.free_all_sheep()
		have_loosed = true


#Test if the player is loosing by testing if the highest sheep is lower than highest_sheep_y + loosing_height
func is_loosing():
	if current_highest_sheep_y > highest_sheep_y + loosing_height:
		return true
	else:
		return false

func end_game():
	if not has_game_ended:
		has_game_ended = true
		dialogue_manager.startDialogue()
	

func _unhandled_input(event: InputEvent):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if have_loosed:
				get_tree().reload_current_scene()
			elif is_debug_mode :
				camera_freeze_height = 0
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and is_debug_mode:
		has_game_ended = true
		end_cinematic_playing = true
		play_end_cinematic()

func play_end_cinematic():
	print("Game finished")
	end_cinematic_playing = true
	var sheeps = sheeps_container.get_children()
	end_cinematic_sheep_count = sheeps.size()
	sheeps.reverse()
	count_sheep_end.visible = true


	var total_time = 0
	for i in range(0,end_cinematic_sheep_count):
		total_time += min(0.5-float(i)/(2*end_cinematic_sheep_count),0.3)
	#tween camera y pos to initial_camera_y
	var tween = create_tween()
	tween.tween_property(camera_2d, "position:y", initial_camera_y, total_time)
	
	#var pos_text = count_sheep_end.position
	#count_sheep_end.add_theme_color_override("font_color", Color.BLACK)
	for i in range(0,end_cinematic_sheep_count):
		# count_sheep_end.global_position = sheeps[i].global_position + Vector2(-390,-30)
		count_sheep_end.text = str(i+1)
		sheeps[i].play_animation_count()
		await get_tree().create_timer(min(0.5-float(i)/(2*end_cinematic_sheep_count),0.3)).timeout
	
	# count_sheep_end.add_theme_color_override("font_color", Color.WHITE)
	# count_sheep_end.position = pos_text
	count_sheep_end.text = str(sheeps.size()) + " sheeps !"

	camera_2d.add_trauma(1)
	var end_camera_pos = Vector2(1087.0,-1236.0)
	var end_camera_zoom = Vector2(0.19,0.19)
	#square tween
	var tween2 = create_tween()
	tween2.tween_property(camera_2d, "position", end_camera_pos, 1)
	tween2.tween_property(camera_2d, "zoom", end_camera_zoom, 1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
