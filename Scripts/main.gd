extends Node2D

const sheep_scene = preload("res://Scenes/sheep.tscn") # Ensure path is correct
var highest_sheep_y = 0

var sheep_count = 0

@onready var camera_2d: Camera2D = $Camera2D
var initial_camera_y = 0


func _ready():
	initial_camera_y = camera_2d.position.y

func _process(delta):
	if sheep_count > 0:
		highest_sheep_y = get_highest_sheep_y()
		if highest_sheep_y < initial_camera_y:
			camera_2d.position.y = lerp(camera_2d.position.y, highest_sheep_y, 0.1)
			# print("Lerping camera y: ", camera_2d.position.y)
		else:
			camera_2d.position.y = lerp(camera_2d.position.y, initial_camera_y, 0.1)
			# print("Lerping camera y: ", camera_2d.position.y)

	# print("Camera y: ", camera_2d.position.y)
	# print("Highest sheep y: ", highest_sheep_y)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#spawn_sheep(get_global_mouse_position())
			return



func spawn_sheep(spawn_position: Vector2):
	sheep_count += 1
	if sheep_scene:
		var sheep_instance = sheep_scene.instantiate()
		add_child(sheep_instance) # Add to scene tree BEFORE setting global_position for RigidBody2D
		sheep_instance.global_position = spawn_position
		print("Spawned sheep at: ", spawn_position)
	else:
		printerr("Sheep scene not loaded!")

func get_highest_sheep_y():
	var highest_sheep_y = 9999
	for sheep in get_children():
		if sheep is Sheep and sheep.have_collided :
			if sheep.global_position.y < highest_sheep_y:
				highest_sheep_y = sheep.global_position.y
	return highest_sheep_y
