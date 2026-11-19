shader_type canvas_item;

uniform sampler2D palette_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Read Pixel Color
	vec4 tex_color = texture(TEXTURE, UV);
	// Set Color
	//tex_color.b = 1.f;
	COLOR = tex_color;
	
	/*
	int idx = int(texture(TEXTURE, UV).r * 255.0);
    int pal_row = 0;
	COLOR = texelFetch(
        palette_texture,
        ivec2(idx, pal_row),
        0
    );
	*/
	
	
	/*
    int idx = int(texture(palette_texture, UV).r * 255.0);
	int pal_row = 0;
    COLOR = texelFetch(
        palette_texture,
        ivec2(idx, pal_row),
        0
    );
	*/
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
