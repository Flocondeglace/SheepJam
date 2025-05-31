extends Sprite2D
var can_be_destroyed:bool=false
func _process(_delta: float) -> void:
	position.x+=2


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if can_be_destroyed:
		print("destroyed")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	can_be_destroyed=true
