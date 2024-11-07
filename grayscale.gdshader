shader_type canvas_item;

uniform float duration : hint_range(0.1, 10.0) = 0.2;
uniform float engine_time_sec;

void fragment() {
    // Calculate mix factor depending on TIME
	float time = clamp(TIME - engine_time_sec, 0.0, duration);
	float factor = pow(time/duration, 0.1);

	// grayscaled verion of the current COLOR
	float gray = 0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b;
	vec3 grayed = vec3(gray, gray, gray);

    // Mix COLOR with the grayscale version, keep alpha
    COLOR = vec4(mix(COLOR.rgb, grayed, factor), COLOR.a);
}