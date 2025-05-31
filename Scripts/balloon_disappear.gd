extends Sprite2D
class_name BalloonDisappear

var moving : bool = false
var speed : float = 0

func _process(_delta: float) -> void:
	self.position.y -= speed

func go_away(s:float):
	moving = true
	speed = s
