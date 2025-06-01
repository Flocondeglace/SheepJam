extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Sheep:
		body.can_be_glued = true


func _on_body_exited(body: Node2D) -> void:
	if body is Sheep:
		body.can_be_glued = false


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("outside") :
		area.get_parent().on_inside_throwing_zone()


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("outside") :
		area.get_parent().on_outside_throwing_zone()
