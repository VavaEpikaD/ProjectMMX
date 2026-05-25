shader_type canvas_item;

// filter_nearest prevents blurry color blending
// repeat_disable stops the palette from wrapping around edges
uniform sampler2D palette : filter_nearest, repeat_disable;

void fragment() {
    // Get the original color of the sprite
    vec4 rgba = texture(TEXTURE, UV);
    
    // In Godot 4, we sample the palette texture using hints
    // We use Red for the X coordinate and Green for the Y coordinate
    vec4 final_color = texture(palette, vec2(rgba.r, rgba.g));
    
    // Preserve the original sprite's transparency
    final_color.a = rgba.a;
    
    COLOR = final_color;
}