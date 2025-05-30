extends RigidBody2D
class_name Sheep2

signal behh

var mouse_hovering : bool = false
var is_hold : bool = false
var time_sickness : float = 5.0
var max_time_sickness : float = 5
@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(delta: float) -> void:
	if is_hold:
		time_sickness += delta
		time_sickness = clamp(time_sickness, 0, max_time_sickness)
		var color_sheep = lerp(Color(1,1,1), Color(0,1,0), time_sickness/max_time_sickness)
		sprite_2d.modulate = color_sheep
		self.linear_velocity = Vector2.ZERO
		self.angular_velocity = 0.0

func launch(direction: Vector2):
	self.apply_impulse(direction)
	end_player_holding()

func is_under_mouse():
	return mouse_hovering

func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false

func start_player_holding() -> void:
	time_sickness = 0
	is_hold = true
	
func end_player_holding() -> void :
	is_hold = false
