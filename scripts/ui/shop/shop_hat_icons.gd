class_name ShopHatIcons
extends RefCounted
## Mağaza listesindeki şapka simgeleri (2D, düz çizim; 3D modelden bağımsız, yalnız liste için).
## Orijin simgenin ortası; yaklaşık ±16 px. Renkler düşük doygunlukta, dünya paletiyle uyumlu.

const W: float = 2.0
const STRAW := Color(0.88, 0.76, 0.50)
const LEATHER := Color(0.58, 0.40, 0.27)
const RED := Color(0.80, 0.33, 0.32)
const CREAM := Color(0.95, 0.93, 0.88)
const NAVY := Color(0.27, 0.32, 0.46)
const TEAL := Color(0.36, 0.64, 0.64)
const PINK := Color(0.90, 0.56, 0.64)
const DARK := Color(0.20, 0.21, 0.26)
const GOLD := Color(0.97, 0.80, 0.38)


static func draw(canvas: CanvasItem, id: StringName) -> void:
	match id:
		&"hat_none":
			_none(canvas)
		&"hat_cap":
			_cap(canvas, TEAL)
		&"hat_beanie":
			_beanie(canvas)
		&"hat_party":
			_cone(canvas, PINK, GOLD, false)
		&"hat_straw":
			_wide(canvas, STRAW, RED, 5.0)
		&"hat_fez":
			_fez(canvas)
		&"hat_cowboy":
			_wide(canvas, LEATHER, PlatformDraw.tone(LEATHER, -0.3), 9.0)
		&"hat_propeller":
			_propeller(canvas)
		&"hat_top":
			_top(canvas)
		&"hat_santa":
			_cone(canvas, RED, CREAM, true)
		&"hat_crown":
			_crown(canvas)
		_:
			_cap(canvas, UiStyle.TEXT_DIM)


## Şapkasız: soluk, kesik çizgili boş daire.
static func _none(canvas: CanvasItem) -> void:
	var color := Color(UiStyle.TEXT_DIM, 0.55)
	canvas.draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, color, W, true)
	canvas.draw_line(Vector2(-7.5, 7.5), Vector2(7.5, -7.5), color, W, true)


static func _dome(center_y: float, half: float, height: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in 13:
		var angle: float = PI + PI * i / 12.0
		points.append(Vector2(cos(angle) * half, center_y + sin(angle) * height))
	return points


static func _cap(canvas: CanvasItem, color: Color) -> void:
	var dome: PackedVector2Array = _dome(4.0, 12.0, 12.0)
	PlatformDraw.shape(canvas, dome, color, W)
	var visor := PackedVector2Array([Vector2(8.0, 2.0), Vector2(19.0, 3.5), Vector2(18.0, 7.0), Vector2(6.0, 6.0)])
	PlatformDraw.shape(canvas, visor, PlatformDraw.tone(color, -0.2), W)
	canvas.draw_circle(Vector2(0.0, -8.0), 1.8, PlatformDraw.tone(color, 0.3), true, -1.0, true)
	canvas.draw_line(Vector2(-6.0, -4.0), Vector2(-3.0, -7.0), Color(1.0, 1.0, 1.0, 0.35), 1.5, true)


static func _beanie(canvas: CanvasItem) -> void:
	PlatformDraw.shape(canvas, _dome(6.0, 12.0, 14.0), NAVY, W)
	var band := PlatformDraw.rounded_rect(Rect2(-13.0, 3.0, 26.0, 7.0), 2.5)
	PlatformDraw.shape(canvas, band, PlatformDraw.tone(NAVY, 0.25), W)
	for x: float in [-7.0, -2.0, 3.0, 8.0]:
		canvas.draw_line(Vector2(x, 4.5), Vector2(x, 8.5), Color(NAVY, 0.8), 1.2, true)
	canvas.draw_circle(Vector2(0.0, -10.0), 4.2, CREAM, true, -1.0, true)
	canvas.draw_arc(Vector2(0.0, -10.0), 4.2, 0.0, TAU, 20, PlatformDraw.OUTLINE_COLOR, W, true)


## Külah (parti / Noel Baba): üçgen gövde, dipte şerit, tepede ponpon; santa uçu yana düşer.
static func _cone(canvas: CanvasItem, color: Color, trim: Color, droop: bool) -> void:
	var tip := Vector2(6.0, -14.0) if droop else Vector2(0.0, -16.0)
	var body := PackedVector2Array([Vector2(-11.0, 8.0), tip, Vector2(11.0, 8.0)])
	PlatformDraw.shape(canvas, body, color, W)
	if not droop:
		for t: float in [0.35, 0.65]:
			canvas.draw_circle(Vector2(-11.0, 8.0).lerp(tip, t) + Vector2(6.0, 0.0), 1.6, trim, true, -1.0, true)
	var band := PlatformDraw.rounded_rect(Rect2(-13.0, 6.0, 26.0, 6.0), 3.0)
	PlatformDraw.shape(canvas, band, trim if droop else PlatformDraw.tone(color, -0.2), W)
	var pom: Vector2 = tip + (Vector2(5.0, 4.0) if droop else Vector2.ZERO)
	canvas.draw_circle(pom, 3.8, trim if droop else GOLD, true, -1.0, true)
	canvas.draw_arc(pom, 3.8, 0.0, TAU, 20, PlatformDraw.OUTLINE_COLOR, W, true)


## Geniş kenarlı şapka (hasır / kovboy): kubbe + yayvan kenar + kurdele.
static func _wide(canvas: CanvasItem, color: Color, ribbon: Color, crown_dip: float) -> void:
	var crown := PackedVector2Array([Vector2(-8.0, 2.0), Vector2(-7.0, -9.0), Vector2(-2.0, -10.0 + crown_dip * 0.3),
			Vector2(2.0, -10.0 + crown_dip * 0.3), Vector2(7.0, -9.0), Vector2(8.0, 2.0)])
	PlatformDraw.shape(canvas, crown, color, W)
	var brim := PackedVector2Array()
	for i: int in 16:
		var angle: float = TAU * i / 16.0
		brim.append(Vector2(cos(angle) * 17.0, 3.0 + sin(angle) * 4.0 - absf(cos(angle)) * crown_dip * 0.25))
	PlatformDraw.shape(canvas, brim, PlatformDraw.tone(color, -0.08), W)
	canvas.draw_line(Vector2(-7.6, -1.0), Vector2(7.6, -1.0), ribbon, 3.0, true)


static func _fez(canvas: CanvasItem) -> void:
	var body := PackedVector2Array([Vector2(-10.0, 9.0), Vector2(-7.0, -9.0), Vector2(7.0, -9.0), Vector2(10.0, 9.0)])
	PlatformDraw.shape(canvas, body, RED, W)
	canvas.draw_line(Vector2(0.0, -9.0), Vector2(5.0, -6.0), DARK, 1.6, true)
	canvas.draw_line(Vector2(5.0, -6.0), Vector2(6.0, 3.0), GOLD, 2.0, true)
	canvas.draw_circle(Vector2(6.0, 4.0), 2.2, GOLD, true, -1.0, true)


static func _propeller(canvas: CanvasItem) -> void:
	_cap(canvas, Color(0.84, 0.62, 0.36))
	canvas.draw_line(Vector2(0.0, -8.0), Vector2(0.0, -13.0), DARK, 2.0, true)
	for side: float in [-1.0, 1.0]:
		var blade := PackedVector2Array([Vector2(0.0, -13.0), Vector2(side * 11.0, -16.0), Vector2(side * 11.0, -12.0)])
		PlatformDraw.shape(canvas, blade, RED if side < 0.0 else TEAL, 1.5)
	canvas.draw_circle(Vector2(0.0, -13.0), 2.0, GOLD, true, -1.0, true)


static func _top(canvas: CanvasItem) -> void:
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(-8.5, -14.0, 17.0, 21.0), 2.0), DARK, W)
	canvas.draw_line(Vector2(-8.0, 2.0), Vector2(8.0, 2.0), RED, 3.0, true)
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(-15.0, 6.0, 30.0, 4.5), 2.2), DARK, W)
	canvas.draw_line(Vector2(-5.5, -11.0), Vector2(-5.5, -3.0), Color(1.0, 1.0, 1.0, 0.25), 1.5, true)


static func _crown(canvas: CanvasItem) -> void:
	var body := PackedVector2Array([Vector2(-13.0, 8.0), Vector2(-14.0, -8.0), Vector2(-7.0, -1.0),
			Vector2(0.0, -12.0), Vector2(7.0, -1.0), Vector2(14.0, -8.0), Vector2(13.0, 8.0)])
	PlatformDraw.shape(canvas, body, GOLD, W)
	canvas.draw_line(Vector2(-12.0, 4.0), Vector2(12.0, 4.0), PlatformDraw.tone(GOLD, -0.2), 2.0, true)
	canvas.draw_circle(Vector2(0.0, 4.0), 2.2, PINK, true, -1.0, true)
	for x: float in [-7.0, 7.0]:
		canvas.draw_circle(Vector2(x, 4.0), 1.7, TEAL, true, -1.0, true)
	PlatformDraw.sparkle(canvas, Vector2(9.0, -12.0), 3.5, Color(1.0, 1.0, 1.0, 0.9))
