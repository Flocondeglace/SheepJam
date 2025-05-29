extends TileMapLayer

@export var selected_scene_id: int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_just_pressed("click"):  # Left mouse button
		var mouse_pos = get_global_mouse_position()
		var grid_pos = local_to_map(mouse_pos)
		print(grid_pos)
		set_cell(grid_pos, 0, Vector2i.ZERO, 1)
