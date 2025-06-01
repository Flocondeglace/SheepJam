extends Node2D
@onready var game : Node2D = $".."
@export var start_spawn_percent:float=0.5
@export var end_spawn_percent:float=0.8
const MONGOLFIERE = preload("res://Scenes/mongolfiere.tscn")
func _on_timer_timeout() -> void:
	if game.progress_percentage >= start_spawn_percent and game.progress_percentage <= end_spawn_percent:
		var mongolfiere =MONGOLFIERE.instantiate()
		var camera_position:Vector2=game.camera_2d.position
		var viewport_size:Vector2=game.camera_2d.get_viewport_rect().size
		var under_camera_position:float=camera_position.y+viewport_size.y + 100
		mongolfiere.position.y=under_camera_position
		mongolfiere.position.x=camera_position.x+randf_range(-viewport_size.x/2,viewport_size.x/2)
		add_child(mongolfiere)
