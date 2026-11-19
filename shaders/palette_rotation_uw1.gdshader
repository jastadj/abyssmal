shader_type canvas_item;

uniform sampler2D index_texture;
uniform sampler2D palette_texture;
uniform int palette_offset = 0;

void fragment()
{
    float idx = texture(index_texture, UV).r * 255.0;

    int shifted = (int(idx) + palette_offset) % 256;

    COLOR = texelFetch(
        palette_texture,
        ivec2(shifted, 0),
        0
    );
}