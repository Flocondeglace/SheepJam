extends Trap
class_name Hole

@onready var fill_zone: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _on_area_detectable_body_entered(body: Node2D) -> void:
	if body is Sheep:
		var sheep: Sheep = body
		sheep.set_trap(self)
		if should_jump:
			sheep.jump()


func _on_area_death_body_entered(body: Node2D) -> void:
	print("here")
	if body is Sheep:
		var sheep: Sheep = body
		print("A Sheep is dying")
		sheep.die()
		call_deferred("fill_hole")
			
func fill_hole():
	print("Filling Hole")
	fill_zone.disabled = false
