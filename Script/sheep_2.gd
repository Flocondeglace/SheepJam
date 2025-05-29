extends RigidBody2D
class_name Sheep2

var mouse_hovering : bool = false

func move(direction: Vector2):
	self.apply_impulse(direction)

func is_under_mouse():
	return mouse_hovering

func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false
