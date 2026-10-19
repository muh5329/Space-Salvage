// Circular HUD glass (radar / target panel): blurred, darkened copy of the scene behind it,
// clipped to a circle with an anti-aliased edge.
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(0.118, 0.161, 0.196, 0.5);   // #1e2932 @ ~50%
uniform float blur_lod = 2.5;
uniform float darken = 0.8;

void fragment() {
	vec2 c = UV * 2.0 - 1.0;
	float r = length(c);
	float px = fwidth(r);
	float mask = 1.0 - smoothstep(1.0 - px * 1.5, 1.0, r);
	vec3 bg = textureLod(screen_tex, SCREEN_UV, blur_lod).rgb * darken;
	bg = mix(bg, tint.rgb, tint.a);
	COLOR = vec4(bg, mask);
}
