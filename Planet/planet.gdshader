shader_type spatial;

global uniform sampler2D gradient;
global uniform vec2 elevation_min_max;

vec4 get_gradient_color(float position) {
    return texture(gradient, vec2(position + 0.005, 0.5));
}

varying vec3 height_gradient;

float inverse_lerp(float a, float b, float t) {
	return (t - a)/(b - a);
}

void vertex() {
	float t = length(VERTEX.xyz);
	float minimum = elevation_min_max.x;
	float maximum = elevation_min_max.y + 0.00001;
	float index = inverse_lerp(minimum, maximum, t) * 256.0;
	vec4 color = get_gradient_color(inverse_lerp(minimum, maximum, t));
	height_gradient = color.rgb;
}

void fragment() {
	ALBEDO = height_gradient;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
