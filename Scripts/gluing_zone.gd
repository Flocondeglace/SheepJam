extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Sheep:
		body.can_be_glued = true


func _on_body_exited(body: Node2D) -> void:
	if body is Sheep:
		body.can_be_glued = false
