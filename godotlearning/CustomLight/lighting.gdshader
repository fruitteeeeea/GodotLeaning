shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// 光源位置 & 半径
uniform vec2 lights[100];
uniform float light_radii[100];
uniform int number_of_lights = 1;

// 颜色控制
uniform vec4 modulate_color : source_color = vec4(0.0);
uniform vec4 light_color : source_color = vec4(1.0);

// 过渡控制
uniform float band_radius = 0.8;
uniform float band_strength = 0.3;


// ✅ 新逻辑：当距离相近时，以半径更大的光源为准
float distance_to_light(vec2 coords, out int nearest_idx) {
	float min_score = 1e9;
	nearest_idx = 0;

	for (int i = 0; i < number_of_lights; i++) {
		float d = distance(coords, lights[i]);
		float r = light_radii[i];

		// 以 "相对距离" 作为比较基准
		// 使得半径大的光源在边界区域更有优势
		float score = d / r;

		if (score < min_score) {
			min_score = score;
			nearest_idx = i;
		}
	}

	// 返回真实距离
	return distance(coords, lights[nearest_idx]);
}



vec4 modulate_light(vec4 color, float dist, float radius) {
	vec4 darkened = color * modulate_color;

	if (dist > radius) {
		return darkened;
	}

	if (dist >= radius * band_radius) {
		return mix(darkened, color * light_color, band_strength);
	}

	return color * light_color;
}


void fragment() {
	vec4 base_color = texture(screen_texture, SCREEN_UV);

	int nearest_idx;
	float dist = distance_to_light(FRAGCOORD.xy, nearest_idx);
	float radius = light_radii[nearest_idx];

	COLOR = modulate_light(base_color, dist, radius);
}