extends Node2D
@onready var camera_2d: Camera2D = $"../Camera2D"
@export var spawn_height = -800
const MONGOLFIERE = preload("res://Scenes/mongolfiere.tscn")
func _on_timer_timeout() -> void:
	if camera_2d.position.y < spawn_height:
		var mongolfiere =MONGOLFIERE.instantiate()
		var camera_position:Vector2=camera_2d.position
		var viewport_size:Vector2=camera_2d.get_viewport_rect().size
		var under_camera_position:float=camera_position.y+viewport_size.y + 100
		mongolfiere.position.y=under_camera_position
		mongolfiere.position.x=camera_position.x+randf_range(-viewport_size.x,viewport_size.x)
		add_child(mongolfiere)
