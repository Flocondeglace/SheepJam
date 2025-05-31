shader_type canvas_item;

uniform vec4 pal_source_1 : source_color  = vec4(1.0,0.929,0.894,1.0);
uniform vec4 pal_source_2 : source_color  = vec4(0.957, 0.855, 0.804, 1.0);
uniform vec4 pal_source_3 : source_color  = vec4(0.894, 0.769, 0.706, 1.0);
uniform vec4 pal_source_4 : source_color  = vec4(1.0,0.969, 0.929, 1.0);

uniform vec4 pal_swap_1 : source_color  = vec4(0.0);
uniform vec4 pal_swap_2 : source_color  = vec4(0.0);
uniform vec4 pal_swap_3 : source_color  = vec4(0.0);
uniform vec4 pal_swap_4 : source_color  = vec4(0.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.a > 0.0)
	{
		if(distance(COLOR, pal_source_1) < 0.01)
		{
			COLOR = pal_swap_1;
		}

		if(distance(COLOR, pal_source_2) < 0.01)
		{
			COLOR = pal_swap_2;
		}

		if(distance(COLOR, pal_source_3) < 0.01)
		{
			COLOR = pal_swap_3;
		}

		if(distance(COLOR, pal_source_4) < 0.01)
		{
			COLOR = pal_swap_4;
		}
	}
}