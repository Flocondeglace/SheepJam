extends Control

@onready var dialogue = $Dialogue

@onready var animation_player: AnimationPlayer = $"../Dieu/AnimationPlayer"


func _process(_delta):
	if dialogue.message_id in [2,4,6,12]:
		if Input.is_action_just_pressed("ui_accept"):
			dialogue.next_message()
	
	if Input.is_action_just_pressed("ui_cancel"):
		dialogue.skip_message()
	
func startDialogue():
	print("start")
	dialogue.start_dialogue()
	animation_player.play("talk")


func onMessageFinished():
	dialogue.next_message()


func onDialogueEnded():
	animation_player.stop()
	print("end")
