shader_type canvas_item;
sd
void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    uv = uv * 2.0 - 1.0; // Normalize UV coordinates to range [-1, 1]
    
    float dist = length(uv);
    if (dist < 1.0) {
        float theta = atan(uv.y, uv.x);
        dist = pow(dist, 0.5); // Adjust the power for the fish eye effect
        uv = dist * vec2(cos(theta), sin(theta));
    }
    
    uv = (uv + 1.0) * 0.5; // Convert back to range [0, 1]
    COLOR = texture(TEXTURE, uv);
}
