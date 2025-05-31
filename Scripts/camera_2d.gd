extends Camera2D

var camera_third_width = 0
var tween_type : Tween.TransitionType = Tween.TRANS_QUART 
var tween_duration = 0.5

func _ready():
	camera_third_width = get_viewport_rect().size.x / 3

func _process(_delta):
	pass

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
