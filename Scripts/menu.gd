extends Node2D

@onready var sheep: Sheep = $SheepsContainer/Sheep2


func _process(_delta):
	if sheep.have_collided:
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
