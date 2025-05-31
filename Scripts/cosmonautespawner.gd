extends Node2D
const MOUTONCOSMONAUTE = preload("res://Scenes/moutoncosmonaute.tscn")


func _on_timer_timeout() -> void:
	var cosmonaute = MOUTONCOSMONAUTE.instantiate()
	add_child(cosmonaute)
	cosmonaute.position = position + randf_range(-400, 400) * Vector2.UP

	
