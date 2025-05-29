extends Node2D
class_name Trap

@onready var label_bubble: Label = $LabelBubble

var should_jump: bool = true
var next_should_jump: bool = true
var first_time: bool = true

func change_sheep_action_next_round():
	print("Changin sheep action next round")
	next_should_jump = !should_jump

func on_next_round_begin():
	if !first_time:
		set_helper(next_should_jump)
	else:
		first_time = false

func set_helper(should: bool):
	label_bubble.visible = true
	should_jump = should
	if should:
		label_bubble.text = "Jump !"
		print("Set helper to jump")
	else:
		label_bubble.text = "Do not jump !"
		print("Set helper to not jump")
