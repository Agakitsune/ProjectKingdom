shader_type canvas_item;

uniform bool active = false;
uniform sampler2D tex: filter_nearest;
uniform int palette = 0;

varying flat int size;

void vertex() {
	size = textureSize(tex, 0).y;
}

void fragment() {
	vec2 texel_size = vec2(
		1.0 / 16.0,
		1.0 / float(size) + 0.001 // avoid precision error
	);
	
	if (active) {
		if (COLOR.a > 0.0) {
			int idx = 0;
			float best = 500.0;
			
			for (int i = 0; i < 16; i++) {
				vec3 clr = texture(tex, vec2(float(i) * texel_size.x, 0.0)).rgb;
				float d = distance(COLOR.rgb, clr);
				if (d < best) {
					idx = i;
					best = d;
				}
			}
			
			COLOR.rgb = texture(
				tex,
				vec2(
					float(idx) * texel_size.x,
					float(palette) * texel_size.y
				)
			).rgb;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
