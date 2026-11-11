shader_type spatial;
// Dış çizgi ("ters kabuk"): model normaller yönünde şişirilir, sadece arka yüzler çizilir.
render_mode unshaded, cull_front;

uniform vec3 outline_color : source_color = vec3(0.86, 0.90, 1.0);
// Model biriminde kalınlık (model yaklaşık 1 birim boyunda).
uniform float outline_width = 0.016;

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = outline_color;
}
