extends Node2D



func get_current_highest_sheep_y():
	var highest_sheep_y = 9999
	for sheep in get_children():
		if sheep is Sheep and sheep.have_collided :
			
			if sheep.global_position.y < highest_sheep_y:
				highest_sheep_y = sheep.global_position.y
	return highest_sheep_y

#freeze sheep if under a certain y under the camera center
func freeze_sheep_under_height(height: float):
	for sheep in get_children():
		if sheep is Sheep and sheep.have_collided:
			if sheep.global_position.y > height:
				sheep.freeze = true

func free_all_sheep():
	for sheep in get_children():
		if sheep is Sheep:
			sheep.free_sheep()
			sheep.animation_player_sprite.play("Dead")
