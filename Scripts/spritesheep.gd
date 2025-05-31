extends Sprite2D

@export var palette_texture: Texture2D
#palette is 4 colors wide and n colors palettes high
var color_palette_list = []
const SHEEP_SHADER = preload("res://Scenes/sheep_shader.tres")
func read_color_palette_from_texture():
	var image = palette_texture.get_image()
	var palette_width = image.get_width()
	var palette_height = image.get_height()
	var palette_colors = []
	#read group of 4 colors from the texture
	for y in range(palette_height):
		for x in range(palette_width):
			var color = image.get_pixel(x, y)
			palette_colors.append(color)
		color_palette_list.append(palette_colors.duplicate())
		palette_colors.clear()
		print(color_palette_list)

func _ready() -> void:
	read_color_palette_from_texture()

	

	#apply the shader to the sprite
	var shader = SHEEP_SHADER.duplicate()
	material = shader
	
	#get first color in list
	var first_color = color_palette_list[0]
	material.set_shader_parameter("pal_source_1", first_color[0])
	material.set_shader_parameter("pal_source_2", first_color[1])
	material.set_shader_parameter("pal_source_3", first_color[2])
	material.set_shader_parameter("pal_source_4", first_color[3])
	
	#randomly select color from the palette
	var random_color = color_palette_list.pick_random()
	print(random_color)
	material.set_shader_parameter("pal_swap_1", random_color[0])
	material.set_shader_parameter("pal_swap_2", random_color[1])
	material.set_shader_parameter("pal_swap_3", random_color[2])
	material.set_shader_parameter("pal_swap_4", random_color[3])
