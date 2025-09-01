shader_type sky;
group_uniforms background;
uniform sampler3D noise;

group_uniforms stars;
uniform vec3 star_base_color: source_color = vec3(0.95, 1.0, 0.9);
uniform float star_hue_offset: hint_range(0., 1.) = 0.8;
uniform float star_intensity: hint_range(0., 0.2) = 0.066;

group_uniforms layers;
uniform float layer_scale: hint_range(0., 60.) = 20.;
uniform float layer_scale_step: hint_range(0., 40.) = 10.;
uniform int layers_count: hint_range(0, 12) = 3;


vec3 hue(vec3 input, float offset, int range_index) {
	vec4 k = vec4(0., -1./3., 2./3., -1.);
	vec4 p = mix(vec4(input.bg, k.wz), vec4(input.gb, k.xy), step(input.b, input.g));
	vec4 q = mix(vec4(p.xyw, input.r), vec4(input.r, p.yzx), step(p.x, input.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.e-10;
	vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6. * d + e)), d / (q.x + e), q.x);

	offset = (range_index == 0) ? offset / 360. : offset;
	float hue = hsv.x + offset;
	if (hue < 0.) {
		hsv.x = hue + 1.;
	} else if (hue > 1.) {
		hsv.x = hue - 1.;
	} else {
		hsv.x = hue;
	}

	vec4 k2 = vec4(1., 2./3., 1./3., 3.);
	vec3 p2 = abs(fract(hsv.xxx + k2.xyz) * 6. - k2.www);
	vec3 rgb = hsv.z * mix(k2.xxx, clamp(p2 - k2.xxx, 0., 1.), hsv.y);
	return rgb;
}

vec3 hash(vec3 x) {
	x = vec3(dot(x, vec3(127.1,311.7, 74.7)),
			 dot(x, vec3(269.5,183.3,246.1)),
			 dot(x, vec3(113.5,271.9,124.6)));
	return fract(sin(x) * 43758.5453123);
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


vec2 voronoi(in vec3 x){
	vec3 p = floor(x);
	vec3 f = fract(x);

	float res = 100.;
	float id = 0.;

	for (float k = -1.; k <= 1.; k += 1.) {
		for (float j = -1.; j <= 1.; j += 1.) {
			for (float i = -1.; i <= 1.; i += 1.) {
				vec3 b = vec3(i, j, k);
				vec3 r = vec3(b) - f + hash(p + b);
				float d = dot(r, r);
				if (d < res) {
					res = d;
					id = dot(p + b, vec3(0., 57., 113.));
				}
		    }
		}
	}

	return vec2(sqrt(res), id);
}

void sky() {
	vec3 background =  vec3(0.6) - texture(noise, EYEDIR.xyz).rgb;
	background *= 0.01;
	background += vec3(0.05, random(EYEDIR.xz) * 0.2, 0.5) * 0.005;
	COLOR = background;

	for (int i = 0; i < layers_count; i++) {
		vec3 pos = EYEDIR * (layer_scale + float(i) * layer_scale_step);
		vec2 layer = voronoi(pos);

		vec3 rand = hash(vec3(layer.y)) * 0.33;
		float star = smoothstep(star_intensity, 0., layer.x);

		vec3 star_color = star * (star_base_color - rand);

		COLOR += star_color;
	}
}
