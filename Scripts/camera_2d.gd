extends Camera2D

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100,75) #Maximum displacement in pixels.
@export var max_roll = 0.0 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.

var noise_y = 0 #Value used to move through the noise
var trauma := 0.0 #Current shake strength
var trauma_pwr := 3 #Trauma exponent. Use [2,3]

var camera_third_width = 0
var tween_type : Tween.TransitionType = Tween.TRANS_QUART 
var tween_duration = 0.5

func _ready():
	camera_third_width = get_viewport_rect().size.x / 3
	randomize()
	print(noise)
	noise.seed = randi()

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		offset.x = lerp(offset.x, 0.0, 1)
		offset.y = lerp(offset.y, 0.0, 1)
		rotation = lerp(rotation, 0.0, 1)

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3, noise_y)

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)

func swipe_right():
	#swipe with tween
	var tween = create_tween().set_trans(tween_type).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:x", position.x + camera_third_width * 2, tween_duration)

func swipe_left():
	#swipe with tween
	var tween = create_tween().set_trans(tween_type).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:x", position.x - camera_third_width * 2, tween_duration)

func _input(event):
	if event.is_action_pressed("swipe_right"):
		swipe_right()
	elif event.is_action_pressed("swipe_left"):
		swipe_left()

func shake_camera(duration: float, strength: float):
	add_trauma(strength)
	
