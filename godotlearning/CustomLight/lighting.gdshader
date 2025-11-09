shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 lights[100];
uniform int number_of_lights = 1;

uniform float band_radius = .8;
uniform float band_strength = 0.3;

uniform vec4 modulate_color : source_color = vec4(0.0);
uniform vec4 light_color : source_color = vec4(1.0); // 🌈 新增：统一光源颜色

uniform float light_radius = 256.0;

float distance_to_light(vec2 coords) {
	float dist = 1000.0;

	for (int i = 0; i < number_of_lights; i++) {
		float new_dist = distance(coords, lights[i]);

		if (new_dist < dist) {
			dist = new_dist;
		}
	}
	return dist;
}


vec4 modulate(vec4 color, float dist) {
	vec4 darkened = color * modulate_color;

	if (dist > light_radius) {
		return darkened;
	}

	if (dist >= light_radius * band_radius) {
		// 边缘区：混合暗部和光照颜色
		return mix(darkened, color * light_color, band_strength);
	}

	// 中心区：完全受光
	return color * light_color;
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR = modulate(COLOR, distance_to_light(FRAGCOORD.xy));
}