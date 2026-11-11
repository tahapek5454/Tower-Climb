class_name Platform
extends StaticBody2D
## Tek yönlü platform: alttan geçilir, üstüne basılır. Orijin üst yüzeyin ortasında.

const COLOR := Color(0.45, 0.62, 0.85)
const SECTION_COLOR := Color(0.95, 0.80, 0.35)
## Üst kenardaki ince açık şerit (derinlik vurgusu): kalınlık ve ne kadar açık olduğu.
const HIGHLIGHT_THICKNESS: float = 3.0
const HIGHLIGHT_LIGHTEN: float = 0.35

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

	var is_section: bool = PlatformRules.is_section_floor(floor_number)
	var color: Color = SECTION_COLOR if is_section else COLOR
	if is_section:
		add_child(_make_section_glow())

	var visual: Polygon2D = Tower.make_rect_visual(size, color)
	visual.position = center
	add_child(visual)

	var highlight: Polygon2D = Tower.make_rect_visual(Vector2(width, HIGHLIGHT_THICKNESS),
			color.lightened(HIGHLIGHT_LIGHTEN))
	highlight.position = Vector2(0.0, HIGHLIGHT_THICKNESS * 0.5)
	add_child(highlight)


## Bölüm platformunun arkasında yumuşak, toplamalı sarı ışık hâlesi.
func _make_section_glow() -> Sprite2D:
	var glow := Sprite2D.new()
	glow.texture = SoftTextures.dot()
	glow.material = SoftTextures.additive()
	glow.modulate = Color(SECTION_COLOR, Tuning.GLOW_SECTION_ALPHA)
	glow.scale = Vector2(width, Tuning.GLOW_SECTION_HEIGHT) / SoftTextures.DOT_SIZE
	glow.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	return glow
