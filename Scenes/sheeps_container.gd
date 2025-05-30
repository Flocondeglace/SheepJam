extends Node2D

func get_highest_sheep_y():
	var highest_sheep_y = 9999
	for sheep in get_children():
		# if sheep is Sheep:
		# 	print(sheep.have_collided)
		if sheep is Sheep and sheep.have_collided :
			
			if sheep.global_position.y < highest_sheep_y:
				highest_sheep_y = sheep.global_position.y
	return highest_sheep_y
