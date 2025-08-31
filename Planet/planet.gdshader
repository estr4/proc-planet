shader_type spatial;

global uniform vec2 elevation_min_max;

varying vec3 height_gradient;

float inverse_lerp(float a, float b, float t) {
	return (t - a)/(b - a);
}

void vertex() {
	float t = length(VERTEX.rgb);
	float minimum = elevation_min_max.r;
	float maximum = elevation_min_max.g + 0.0001;
	height_gradient = vec3(inverse_lerp(minimum, maximum, t));
}

void fragment() {
	ALBEDO = height_gradient;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
