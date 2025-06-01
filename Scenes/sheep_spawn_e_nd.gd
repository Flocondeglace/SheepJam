extends Node2D
@onready var line_2d: Line2D = $Line2D
@onready var timer: Timer = $Timer
@onready var game = $".."

var x1 = 0.0
var x2 = 0.0
var y = 0.0


func _ready():
	x1 = line_2d.points[0].x
	x2 = line_2d.points[1].x
	y = line_2d.points[1].y


func _on_timer_timeout() -> void:
	var random_x = randf_range(x1,x2)
	var random_y = randf_range(y,y+100)
	var sheep = game.spawn_sheep(Vector2(random_x,random_y))
	sheep.rotation = randf_range(0,360)
	sheep.sprite_2d.scale = Vector2(8,8)
	sheep.collision_shape.disabled = true
	sheep.collision_shape_gluing.disabled = true
	sheep.kill_after_time(10)
