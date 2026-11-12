class_name Platform
extends StaticBody2D
## Tek yönlü platform: alttan geçilir, üstüne basılır. Orijin üst yüzeyin ortasında.

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
	if is_section:
		add_child(_make_section_glow())

	var visual := PlatformVisual.new()
	visual.name = "Visual"
	visual.setup(width, WorldPalette.PLATFORM_SECTION if is_section else _theme_color(), floor_number)
	add_child(visual)


## Platformun kendi katındaki tema rengi (geçiş bölgesinde iki tema arası).
func _theme_color() -> Color:
	var theme_position: float = ThemeRules.position(float(floor_number))
	return WorldPalette.colors_at(theme_position)[&"platform"]


## Bölüm platformunun arkasında yumuşak, toplamalı sarı ışık hâlesi.
func _make_section_glow() -> Sprite2D:
	var glow := Sprite2D.new()
	glow.texture = SoftTextures.dot()
	glow.material = SoftTextures.additive()
	glow.modulate = Color(WorldPalette.PLATFORM_SECTION, Tuning.GLOW_SECTION_ALPHA)
	glow.scale = Vector2(width, Tuning.GLOW_SECTION_HEIGHT) / SoftTextures.DOT_SIZE
	glow.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	return glow
