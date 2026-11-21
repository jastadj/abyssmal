shader_type canvas_item;

uniform sampler2D palette_texture;
uniform int palette_index = 0;

uniform bool has_mapper = false;
uniform sampler2D mapper_texture;
uniform int mapper_index = 0;

void fragment()
{
    int idx = int(texture(TEXTURE, UV).r * 255.0);

	if(has_mapper)
	{
		idx = int(texelFetch(
	        mapper_texture,
	        ivec2(idx, mapper_index),
	        0
	    ).r * 255.0);
	}
	COLOR = texelFetch(
		        palette_texture,
		        ivec2(idx, palette_index),
		        0
		    );
}