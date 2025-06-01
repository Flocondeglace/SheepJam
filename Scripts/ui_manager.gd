extends CanvasLayer

@onready var animation_transition: AnimationPlayer = $Transition/AnimationPlayer


func _on_home_button_pressed() -> void:
	animation_transition.play("transition")
	await animation_transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
