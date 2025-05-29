class_name Peak
extends Node2D


func _on_area_death_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Sheep:
		var sheep: Sheep = parent
		sheep.die()
