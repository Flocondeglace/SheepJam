extends Trap
class_name Spike

@onready var label_bubble: Label = $LabelBubble

var should_jump: bool = false
var next_should_jump: bool = false
var first_time: bool = true

#func _process(_delta) -> void:
	#if Input.is_action_just_pressed("debug"):
		#set_helper(!should_jump)

func on_next_round_begin():
	if !first_time:
		set_helper(next_should_jump)
	else:
		first_time = false
	
func change_sheep_action_next_round():
	next_should_jump = !should_jump

func set_helper(should: bool):
	label_bubble.visible = true
	should_jump = should
	if should:
		label_bubble.text = "Jump !"
		print("Set helper to jump")
	else:
		label_bubble.text = "Do not jump !"
		print("Set helper to not jump")

func _on_area_detectable_body_entered(body: Node2D) -> void:
	print("Area detectable entered")
	if body is Sheep:
		var sheep: Sheep = body
		if should_jump:
			print("A Sheep is jumping")
			sheep.jump()
			sheep.set_trap(self)


func _on_area_death_body_entered(body: Node2D) -> void:
	print("Area death entered")
	if body is Sheep:
		var sheep: Sheep = body
		print("A Sheep is dying")
		sheep.die()
