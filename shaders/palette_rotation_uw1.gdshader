shader_type canvas_item;

uniform sampler2D palette_texture;
uniform int palette_index = 0;

uniform bool has_aux_palette = false;
uniform sampler2D aux_palette_texture;
uniform int aux_palette = 0;

uniform bool has_mapper = false;
uniform sampler2D mapper_texture;
uniform int mapper_index = 0;

int rotate_pixel(int idx, float tick, int start, int end, bool up)
{
	int state = int(mod(tick, float(end - start + 1)));
	if(!up)
	{
		idx += state;
		if(idx > end)
		{
			idx = idx - end + start - 1;
		}
	}
	else
	{
		idx -= state;
		if(idx < start)
		{
			idx = end - start + 1 + idx;
		}
	}
	return idx;
}

void fragment()
{
    int idx = int(texture(TEXTURE, UV).r * 255.0);
	
	// aux palette mapping
	if(has_aux_palette)
	{
		idx = int(texelFetch(
	        aux_palette_texture,
	        ivec2(idx, aux_palette),
	        0
	    ).r * 255.0);
	}
	
	// remap index if mapper is used
	if(has_mapper)
	{
		idx = int(texelFetch(
	        mapper_texture,
	        ivec2(idx, mapper_index),
	        0
	    ).r * 255.0);
	}
	
	// pixel rotations (palette 0 only)
	if(palette_index == 0)
	{
		float tick = floor(TIME * 4.0);
		// fire/lava effect
		if(idx >= 16 && idx <= 23)
		{
			if(idx <= 20)
			{
				idx = rotate_pixel(idx, tick, 16, 20, true);
			}
			else
			{
				idx = rotate_pixel(idx, tick, 21, 23, true);
			}
		}
		else if(idx >= 48 && idx <= 63)
		{
			if(idx <= 51)
			{
				idx = rotate_pixel(idx, tick, 48, 51, false);
			}
			else if(idx <= 55)
			{
				idx = rotate_pixel(idx, tick, 52, 55, false);
			}
			else if(idx <= 59)
			{
				idx = rotate_pixel(idx, tick, 56, 59, false);
			}
			else
			{
				idx = rotate_pixel(idx, tick, 60, 63, false);
			}
		}
	}
	// main menu
	else if(palette_index == 2)
	{
		float tick = floor(TIME * 4.0);
		if(idx >= 64 && idx <= 127)
		{
			idx = rotate_pixel(idx, tick, 64, 127, true);
		}
	}

	COLOR = texelFetch(
		        palette_texture,
		        ivec2(idx, palette_index),
		        0
		    );
}