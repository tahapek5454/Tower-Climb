class_name PlatformVisual
extends Node2D
## Platformun görüntüsü. Orijin üst yüzeyin ortasında (Platform ile aynı). Sadece çizim;
## çarpışma Platform'da. Her genişliğe kendiliğinden uyar.
## Stiller: &"blocks" (bu dosyada: düzenli taş bloklar, başlık taşları, destekler),
## &"masonry", &"rock" (PlatformStylesStone), &"plank", &"metal", &"ice", &"crystal"
## (PlatformStylesThemed), &"cobble", &"arch", &"log", &"truss", &"pipe" (PlatformStylesBuilt),
## &"snowdrift", &"cloud", &"glow_tiles" (PlatformStylesSoft).
## Rastgelelik variation_seed'den: aynı kat hep aynı görünür.

## Yeni stillerin arka duvara düşen gölgesi: aşağı kayma (px) ve koyuluk.
const SHADOW_OFFSET: float = 5.0
const SHADOW_ALPHA: float = 0.22

var _width: float = 0.0
var _color: Color = Color.WHITE
var _variation_seed: int = 0
var _style: StringName = &"blocks"
var _decor_theme: int = -1


## add_child'dan önce çağrılır. variation_seed: rastgeleliğin tohumu (ör. kat numarası).
## decor_theme: süslerin teması (PlatformDecor); -1 = süs yok.
func setup(width: float, color: Color, variation_seed: int, style: StringName = &"blocks",
		decor_theme: int = -1) -> void:
	_width = width
	_color = color
	_variation_seed = variation_seed
	_style = style
	_decor_theme = decor_theme


func _draw() -> void:
	if _style == &"blocks":
		_draw_blocks_style()
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_variation_seed)
	var shadow := Rect2(-_width * 0.5 + 3.0, SHADOW_OFFSET, _width - 6.0, Tuning.PLATFORM_THICKNESS)
	draw_colored_polygon(PlatformDraw.rounded_rect(shadow, 8.0), Color(0.0, 0.0, 0.0, SHADOW_ALPHA))
	# Süsler kendi rng'siyle: stil çizimi kaç sayı çekerse çeksin süsler aynı kalır.
	var decor_rng := RandomNumberGenerator.new()
	decor_rng.seed = hash(_variation_seed * 31 + 7)
	var decor: Array[StringName] = []
	if _decor_theme >= 0:
		decor = PlatformDecor.pick(_decor_theme, _style, decor_rng)
		PlatformDecor.draw_behind(self, _width, decor, decor_rng)
	match _style:
		&"masonry": PlatformStylesStone.masonry(self, _width, _color, rng)
		&"rock": PlatformStylesStone.rock(self, _width, _color, rng)
		&"plank": PlatformStylesThemed.plank(self, _width, _color, rng)
		&"metal": PlatformStylesThemed.metal(self, _width, _color, rng)
		&"ice": PlatformStylesThemed.ice(self, _width, _color, rng)
		&"crystal": PlatformStylesThemed.crystal(self, _width, _color, rng)
		&"cobble": PlatformStylesBuilt.cobble(self, _width, _color, rng)
		&"arch": PlatformStylesBuilt.arch(self, _width, _color, rng)
		&"log": PlatformStylesBuilt.wood_log(self, _width, _color, rng)
		&"truss": PlatformStylesBuilt.truss(self, _width, _color, rng)
		&"pipe": PlatformStylesBuilt.pipe(self, _width, _color, rng)
		&"snowdrift": PlatformStylesSoft.snowdrift(self, _width, _color, rng)
		&"cloud": PlatformStylesSoft.cloud(self, _width, _color, rng)
		&"glow_tiles": PlatformStylesSoft.glow_tiles(self, _width, _color, rng)
		_: push_error("Bilinmeyen platform stili: %s" % _style)
	PlatformDecor.draw_front(self, _width, decor, decor_rng)


func _draw_blocks_style() -> void:
	var thickness: float = Tuning.PLATFORM_THICKNESS
	var left: float = -_width * 0.5
	var cap_width: float = minf(Tuning.PLATFORM_CAP_WIDTH, _width * 0.5)
	var cap_size := Vector2(cap_width, thickness + Tuning.PLATFORM_CAP_DROP)

	_draw_corbels(thickness, cap_width)
	_draw_block(Rect2(left, 0.0, _width, thickness), _color, true)
	_draw_stones(left + cap_width, _width - cap_width * 2.0, thickness)
	var cap_color: Color = _color.lightened(Tuning.PLATFORM_CAP_LIGHTEN)
	_draw_block(Rect2(Vector2(left, 0.0), cap_size), cap_color, false)
	_draw_block(Rect2(Vector2(-left - cap_width, 0.0), cap_size), cap_color, false)


## Yuvarlak köşeli taş blok: koyu alt kenar (+ istenirse gölge), açık üst şerit, gövde.
func _draw_block(rect: Rect2, color: Color, with_shadow: bool) -> void:
	var radius: int = int(Tuning.PLATFORM_CORNER_RADIUS)
	var top_height: float = Tuning.PLATFORM_TOP_HEIGHT
	var body_height: float = rect.size.y - Tuning.PLATFORM_UNDERSIDE_HEIGHT

	var underside: StyleBoxFlat = _make_layer(color.darkened(Tuning.PLATFORM_UNDERSIDE_DARKEN),
			radius, radius)
	if with_shadow:
		underside.shadow_color = Color(0.0, 0.0, 0.0, Tuning.PLATFORM_SHADOW_ALPHA)
		underside.shadow_size = int(Tuning.PLATFORM_SHADOW_SIZE)
		underside.shadow_offset = Vector2(0.0, Tuning.PLATFORM_SHADOW_OFFSET)
	draw_style_box(underside, rect)

	# Üst şerit: gövdenin tamamı açık renkte, asıl renk bunun üstüne biraz aşağıdan başlar.
	draw_style_box(_make_layer(color.lightened(Tuning.PLATFORM_TOP_LIGHTEN), radius, radius),
			Rect2(rect.position, Vector2(rect.size.x, body_height)))
	var inner_radius: int = maxi(radius - int(top_height), 0)
	draw_style_box(_make_layer(color, inner_radius, radius),
			Rect2(rect.position + Vector2(0.0, top_height),
			Vector2(rect.size.x, body_height - top_height)))


## Başlıklar arasındaki taşlar: her biri hafif farklı tonda, aralarında koyu derz.
func _draw_stones(start_x: float, span: float, thickness: float) -> void:
	if span <= 0.0:
		return
	var top_height: float = Tuning.PLATFORM_TOP_HEIGHT
	var body_height: float = thickness - Tuning.PLATFORM_UNDERSIDE_HEIGHT - top_height
	var count: int = maxi(1, roundi(span / Tuning.PLATFORM_STONE_LENGTH))
	var stone_width: float = span / float(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_variation_seed)

	for i: int in count:
		var tone: float = rng.randf_range(-1.0, 1.0) * Tuning.PLATFORM_STONE_VARIATION
		var stone_color: Color = _color.lightened(tone) if tone > 0.0 else _color.darkened(-tone)
		draw_rect(Rect2(start_x + stone_width * i, top_height, stone_width, body_height), stone_color)

	var joint_width: float = Tuning.PLATFORM_JOINT_WIDTH
	var joint_color: Color = _color.darkened(Tuning.PLATFORM_JOINT_DARKEN)
	for i: int in range(1, count):
		var x: float = start_x + stone_width * i - joint_width * 0.5
		# Üst şeritte küçük bir çentik, altında koyu derz.
		draw_rect(Rect2(x, 0.0, joint_width, top_height), _color)
		draw_rect(Rect2(x, top_height, joint_width, thickness - top_height), joint_color)


## Levhanın altında, iki uca yakın küçük destek taşları (aşağı doğru daralan).
func _draw_corbels(thickness: float, cap_width: float) -> void:
	var half_top: float = Tuning.PLATFORM_CORBEL_WIDTH * 0.5
	var center_x: float = _width * 0.5 - cap_width - Tuning.PLATFORM_CORBEL_INSET - half_top
	if center_x < half_top:
		return
	var half_bottom: float = half_top * Tuning.PLATFORM_CORBEL_TAPER
	var top_y: float = thickness - Tuning.PLATFORM_UNDERSIDE_HEIGHT
	var bottom_y: float = thickness + Tuning.PLATFORM_CORBEL_HEIGHT
	var color: Color = _color.darkened(Tuning.PLATFORM_CORBEL_DARKEN)
	for side: float in [-1.0, 1.0]:
		var x: float = center_x * side
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - half_top, top_y), Vector2(x + half_top, top_y),
			Vector2(x + half_bottom, bottom_y), Vector2(x - half_bottom, bottom_y),
		]), color)


func _make_layer(color: Color, top_radius: int, bottom_radius: int) -> StyleBoxFlat:
	var layer := StyleBoxFlat.new()
	layer.bg_color = color
	layer.corner_radius_top_left = top_radius
	layer.corner_radius_top_right = top_radius
	layer.corner_radius_bottom_left = bottom_radius
	layer.corner_radius_bottom_right = bottom_radius
	return layer
