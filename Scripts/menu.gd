extends Node2D

@onready var sheep: Sheep = $SheepsContainer/Sheep2
@onready var animation_transition: AnimationPlayer = $Transition/AnimationPlayer
var transition : bool = false

func _process(_delta):
	if sheep.have_collided && !transition:
		transition = true
		do_transition()

func do_transition():
	await get_tree().create_timer(1).timeout
	animation_transition.play("transition")
	await animation_transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
