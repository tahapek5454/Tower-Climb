class_name Platform
extends StaticBody2D
## Tek yönlü platform: alttan geçilir, üstüne basılır. Orijin üst yüzeyin ortasında.

const COLOR := Color(0.45, 0.62, 0.85)
const SECTION_COLOR := Color(0.95, 0.80, 0.35)

var floor_number: int = 0
var width: float = 0.0


## add_child'dan önce çağrılır; çarpışma şeklini ve görseli kurar.
func setup(p_floor_number: int, p_width: float) -> void:
	floor_number = p_floor_number
	width = p_width
	var size := Vector2(width, Tuning.PLATFORM_THICKNESS)
	var center := Vector2(0.0, size.y * 0.5)

	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = center
	collider.one_way_collision = true
	collider.one_way_collision_margin = Tuning.PLATFORM_ONE_WAY_MARGIN
	add_child(collider)

	var color: Color = SECTION_COLOR if PlatformRules.is_section_floor(floor_number) else COLOR
	var visual: Polygon2D = Tower.make_rect_visual(size, color)
	visual.position = center
	add_child(visual)
