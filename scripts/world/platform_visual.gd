class_name PlatformVisual
extends Node2D
## Platformun görüntüsü: yuvarlak köşeli levha, üstte açık şerit, altta koyu kenar ve hafif gölge.
## Orijin üst yüzeyin ortasında (Platform ile aynı). Sadece çizim; çarpışma Platform'da.

var _layers: Array[StyleBoxFlat] = []
var _rects: Array[Rect2] = []


## add_child'dan önce çağrılır.
func setup(width: float, color: Color) -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var radius: int = int(Tuning.PLATFORM_CORNER_RADIUS)
	var top_height: float = Tuning.PLATFORM_TOP_HEIGHT
	var body_bottom: float = thickness - Tuning.PLATFORM_UNDERSIDE_HEIGHT
	var left: float = -width * 0.5

	# Alt kenar: tüm levha koyu renkte çizilir, üstüne gelen katmanlar altta ince bir kenar bırakır.
	var underside: StyleBoxFlat = _make_layer(color.darkened(Tuning.PLATFORM_UNDERSIDE_DARKEN),
			radius, radius)
	underside.shadow_color = Color(0.0, 0.0, 0.0, Tuning.PLATFORM_SHADOW_ALPHA)
	underside.shadow_size = int(Tuning.PLATFORM_SHADOW_SIZE)
	underside.shadow_offset = Vector2(0.0, Tuning.PLATFORM_SHADOW_OFFSET)
	_add_layer(underside, Rect2(left, 0.0, width, thickness))

	# Üst şerit: gövdenin tamamı açık renkte, asıl renk bunun üstüne biraz aşağıdan başlar.
	_add_layer(_make_layer(color.lightened(Tuning.PLATFORM_TOP_LIGHTEN), radius, radius),
			Rect2(left, 0.0, width, body_bottom))

	var inner_radius: int = maxi(radius - int(top_height), 0)
	_add_layer(_make_layer(color, inner_radius, radius),
			Rect2(left, top_height, width, body_bottom - top_height))


func _draw() -> void:
	for i: int in _layers.size():
		draw_style_box(_layers[i], _rects[i])


func _add_layer(layer: StyleBoxFlat, rect: Rect2) -> void:
	_layers.append(layer)
	_rects.append(rect)


func _make_layer(color: Color, top_radius: int, bottom_radius: int) -> StyleBoxFlat:
	var layer := StyleBoxFlat.new()
	layer.bg_color = color
	layer.corner_radius_top_left = top_radius
	layer.corner_radius_top_right = top_radius
	layer.corner_radius_bottom_left = bottom_radius
	layer.corner_radius_bottom_right = bottom_radius
	return layer
