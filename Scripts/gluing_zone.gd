extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Sheep:
		body.can_be_glued = true
