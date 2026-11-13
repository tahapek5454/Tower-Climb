class_name ShopIcons
extends RefCounted
## Mağaza ürün simgeleri (2D): şapka (ShopHatIcons), tişört ve pantolon (katalog rengi + desen),
## efekt (renkli iz kuyruğu), takviye ve yükseltmeler (oyundaki güçlendirme çizimleri).
## Orijin simgenin ortası; ölçek 1'de yaklaşık 36 x 36 px.

const W: float = 2.0
const SHIRT_POINTS: Array[Vector2] = [
	Vector2(-5.0, -12.0), Vector2(-13.0, -9.0), Vector2(-18.0, -2.0), Vector2(-13.0, 1.5), Vector2(-11.0, -1.0),
	Vector2(-11.0, 13.0), Vector2(11.0, 13.0), Vector2(11.0, -1.0), Vector2(13.0, 1.5), Vector2(18.0, -2.0),
	Vector2(13.0, -9.0), Vector2(5.0, -12.0), Vector2(2.5, -9.0), Vector2(0.0, -8.2), Vector2(-2.5, -9.0),
]
const PANTS_POINTS: Array[Vector2] = [
	Vector2(-11.0, -13.0), Vector2(11.0, -13.0), Vector2(12.5, 13.0), Vector2(3.0, 13.0), Vector2(0.0, -1.0),
	Vector2(-3.0, 13.0), Vector2(-12.5, 13.0),
]
const TRAIL_DOTS: int = 9
const CLOVER := Color(0.50, 0.74, 0.52)
## Takviye/yükseltme simgelerinin oyundaki çizime göre ölçeği (çizimler simge kutusundan büyük).
const ART_SCALE: float = 0.78


static func draw(canvas: CanvasItem, item: Dictionary, center: Vector2, scale: float = 1.0) -> void:
	canvas.draw_set_transform(center, 0.0, Vector2.ONE * scale)
	match item.get("category", &""):
		ShopCatalog.HAT:
			ShopHatIcons.draw(canvas, item["id"])
		ShopCatalog.SHIRT:
			_shirt(canvas, item)
		ShopCatalog.PANTS:
			_pants(canvas, item)
		ShopCatalog.TRAIL:
			draw_trail(canvas, item)
		ShopCatalog.BOOST, ShopCatalog.UPGRADE:
			canvas.draw_set_transform(center, 0.0, Vector2.ONE * scale * ART_SCALE)
			_power(canvas, item["id"])
	canvas.draw_set_transform(Vector2.ZERO)


## Efektin renk takımı: düz (color → color2), gökkuşağı (ton döner), parıltı (+ yıldızcıklar).
static func trail_color(item: Dictionary, t: float) -> Color:
	if item.get("style", &"") == ShopCatalog.STYLE_RAINBOW:
		return Color.from_hsv(fposmod(0.98 + t * 0.75, 1.0), 0.45, 1.0)
	return (item.get("color", UiStyle.ACCENT) as Color).lerp(item.get("color2", UiStyle.ACCENT), t)


## Sol alttan sağ üste kıvrılan, giderek kalınlaşan nokta kuyruğu.
static func draw_trail(canvas: CanvasItem, item: Dictionary) -> void:
	for i: int in TRAIL_DOTS:
		var t: float = float(i) / (TRAIL_DOTS - 1)
		var point: Vector2 = _bezier(Vector2(-15.0, 11.0), Vector2(-6.0, -12.0), Vector2(14.0, -9.0), t)
		var color: Color = trail_color(item, t)
		canvas.draw_circle(point, lerpf(1.6, 5.2, t), Color(color, lerpf(0.25, 1.0, t)), true, -1.0, true)
	if item.get("style", &"") == ShopCatalog.STYLE_SPARKLE:
		var spark: Color = item.get("color2", Color.WHITE)
		PlatformDraw.sparkle(canvas, Vector2(-9.0, -5.0), 3.2, spark)
		PlatformDraw.sparkle(canvas, Vector2(4.0, 6.0), 2.6, spark)
		PlatformDraw.sparkle(canvas, Vector2(13.0, -15.0), 2.2, spark)


static func _bezier(a: Vector2, control: Vector2, b: Vector2, t: float) -> Vector2:
	return a.lerp(control, t).lerp(control.lerp(b, t), t)


static func _shirt(canvas: CanvasItem, item: Dictionary) -> void:
	var points := PackedVector2Array(SHIRT_POINTS)
	var color: Color = item.get("color", UiStyle.TEXT_DIM)
	var accent: Color = item.get("color2", color)
	canvas.draw_colored_polygon(points, color)
	match item.get("pattern", &""):
		ShopCatalog.PATTERN_STRIPES:
			for y: float in [-3.5, 2.5, 8.5]:
				canvas.draw_rect(Rect2(-11.0, y, 22.0, 3.0), accent)
		ShopCatalog.PATTERN_DOTS:
			for dot: Vector2 in [Vector2(-6.0, -3.0), Vector2(4.0, -4.0), Vector2(-1.0, 3.0), Vector2(7.0, 5.0),
					Vector2(-7.0, 8.0), Vector2(2.0, 10.0)]:
				canvas.draw_circle(dot, 1.8, accent, true, -1.0, true)
		ShopCatalog.PATTERN_STAR:
			canvas.draw_colored_polygon(_star(Vector2(0.0, 3.0), 6.5, 2.8), accent)
	# Yaka ve hafif ışık.
	canvas.draw_polyline(PackedVector2Array([Vector2(-5.0, -12.0), Vector2(-2.5, -9.0), Vector2(0.0, -8.2),
			Vector2(2.5, -9.0), Vector2(5.0, -12.0)]), PlatformDraw.tone(color, -0.25), 2.0, true)
	canvas.draw_line(Vector2(-8.0, 1.0), Vector2(-8.0, 9.0), Color(1.0, 1.0, 1.0, 0.18), 2.0, true)
	PlatformDraw.outline(canvas, points, W)


static func _pants(canvas: CanvasItem, item: Dictionary) -> void:
	var points := PackedVector2Array(PANTS_POINTS)
	var color: Color = item.get("color", UiStyle.TEXT_DIM)
	canvas.draw_colored_polygon(points, color)
	canvas.draw_line(Vector2(-11.0, -9.0), Vector2(11.0, -9.0), PlatformDraw.tone(color, -0.3), 2.0, true)
	canvas.draw_line(Vector2(0.0, -9.0), Vector2(0.0, -3.0), PlatformDraw.tone(color, -0.3), 1.4, true)
	canvas.draw_line(Vector2(-8.0, -6.0), Vector2(-9.0, 10.0), Color(1.0, 1.0, 1.0, 0.18), 2.0, true)
	PlatformDraw.outline(canvas, points, W)


static func _power(canvas: CanvasItem, id: StringName) -> void:
	match id:
		ShopCatalog.BOOST_HEART:
			HeartArt.draw(canvas, Vector2(0.0, -2.0), 1.15)
		ShopCatalog.BOOST_ROCKET:
			JetpackArt.draw(canvas, 0.8)
		ShopCatalog.UP_JETPACK:
			JetpackArt.draw(canvas, 0.0)
		ShopCatalog.UP_HOURGLASS:
			HourglassArt.draw(canvas, 0.6)
		ShopCatalog.UP_MAGNET:
			MagnetArt.draw(canvas, Vector2.ZERO, 1.2)
		ShopCatalog.UP_HEARTS:
			HeartArt.draw(canvas, Vector2(-7.0, 3.0), 0.85)
			HeartArt.draw(canvas, Vector2(7.0, -4.0), 0.85)
		ShopCatalog.UP_LUCK:
			_clover(canvas)


static func _clover(canvas: CanvasItem) -> void:
	canvas.draw_line(Vector2(0.0, 2.0), Vector2(5.0, 18.0), PlatformDraw.tone(CLOVER, -0.3), 3.0, true)
	for angle: float in [0.0, PI * 0.5, PI, PI * 1.5]:
		var leaf: Vector2 = Vector2(cos(angle + PI * 0.25), sin(angle + PI * 0.25)) * 7.5
		canvas.draw_circle(leaf, 7.0, PlatformDraw.OUTLINE_COLOR, true, -1.0, true)
	for angle: float in [0.0, PI * 0.5, PI, PI * 1.5]:
		var leaf: Vector2 = Vector2(cos(angle + PI * 0.25), sin(angle + PI * 0.25)) * 7.5
		canvas.draw_circle(leaf, 5.4, CLOVER, true, -1.0, true)
		canvas.draw_circle(leaf + Vector2(-1.5, -1.5), 1.6, Color(1.0, 1.0, 1.0, 0.35), true, -1.0, true)


static func _star(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in 10:
		var radius: float = outer if i % 2 == 0 else inner
		var angle: float = -PI * 0.5 + PI * i / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points
