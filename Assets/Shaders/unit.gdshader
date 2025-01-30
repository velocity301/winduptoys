shader_type canvas_item;

uniform vec4 team_color = vec4(1.0, 1.0, 1.0, 1.0); // Default to white

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Print debug color output (only works in Visual Shader Debug Mode)
    // Uncomment this if using a print debugger in visual shaders
    // COLOR = vec4(1.0, 0.0, 1.0, 1.0); return; // Temporary pink output to test

    // Replace near-white pixels with the team color
    if (tex_color.r > 0.9 && tex_color.g > 0.9 && tex_color.b > 0.9) {
        tex_color.rgb = team_color.rgb;
    }

    COLOR = tex_color;
}
