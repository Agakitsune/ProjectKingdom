shader_type canvas_item;

uniform bool active = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (active) {
		float s = sin(TIME * 64.0) + 1.0;
		s /= 2.0;
		s *= 0.5;
		s += 0.5;
		COLOR.a *= s;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
