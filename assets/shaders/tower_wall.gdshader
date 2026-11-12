shader_type canvas_item;
// Kule yan duvarı: koyu taş sütun. Aralıklı yatay derzler (dünya koordinatında sabit),
// kule içine bakan kenarda açık renkli ince pervaz, dış kenara doğru hafif kararma.

uniform vec4 wall_color : source_color = vec4(0.16, 0.18, 0.26, 1.0);
uniform vec4 joint_color : source_color = vec4(0.12, 0.135, 0.20, 1.0);
uniform vec4 lip_color : source_color = vec4(0.27, 0.30, 0.42, 1.0);
// Duvarın dünya x merkezi ve kalınlığı (px).
uniform float center_x = 0.0;
uniform float thickness = 48.0;
// Kule içi duvarın hangi yanında: +1 = sağında (sol duvar), -1 = solunda (sağ duvar).
uniform float inner_sign = 1.0;
// Sütun parçalarının yüksekliği ve aralarındaki derzin kalınlığı (px).
uniform float segment_height = 256.0;
uniform float joint_width = 3.0;
// İç kenardaki pervazın genişliği (px) ve dış kenardaki kararma oranı.
uniform float lip_width = 5.0;
uniform float outer_shade = 0.15;

varying vec2 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	// Dış kenardan (0) iç kenara (thickness) uzaklık.
	float across = clamp((world_pos.x - center_x) * inner_sign + thickness * 0.5, 0.0, thickness);
	vec3 color = wall_color.rgb * (1.0 - outer_shade * (1.0 - across / thickness));

	float along = fract(world_pos.y / segment_height) * segment_height;
	float joint_distance = min(along, segment_height - along);
	float joint = 1.0 - smoothstep(joint_width * 0.5 - 0.5, joint_width * 0.5 + 0.5, joint_distance);
	color = mix(color, joint_color.rgb, joint);

	float lip_start = thickness - lip_width;
	float lip = smoothstep(lip_start - 0.5, lip_start + 0.5, across);
	color = mix(color, lip_color.rgb, lip);

	COLOR = vec4(color, 1.0);
}
