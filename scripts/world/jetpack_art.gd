class_name JetpackArt
extends RefCounted
## Roketin (jetpack) 2D çizimi ve ortak renkleri. Toplanabilir nesne ve bırakılan boş roket bunu çizer;
## karakterin sırtındaki 3D roket (JetpackModel) aynı renkleri kullanır.
## Orijin gövdenin ortasında; yaklaşık 36 x 46 px (alev hariç).

## İki yakıt tüpü (sıcak mercan-turuncu: ödül ailesi), krem bant, altın burun, koyu gri meme.
const BODY := Color(0.93, 0.43, 0.25)
const BAND := Color(0.97, 0.91, 0.80)
const CAP := Color(0.99, 0.80, 0.38)
const NOZZLE := Color(0.34, 0.37, 0.46)
const FRAME := Color(0.24, 0.27, 0.36)
const FLAME_OUTER := Color(1.0, 0.60, 0.20)
const FLAME_INNER := Color(1.0, 0.93, 0.62)

const TANK_SIZE := Vector2(15.0, 34.0)
## Tüp merkezlerinin ortadan uzaklığı ve gövdenin üst kenarı.
const TANK_OFFSET_X: float = 9.5
const TANK_TOP: float = -20.0
const OUTLINE_WIDTH: float = 2.0
const NOZZLE_HEIGHT: float = 6.0
const FLAME_LENGTH: float = 9.0


## flame: 0 = alev yok, 1 = tam alev (titreşim için 0..1 arası değişen değer verilebilir).
static func draw(canvas: CanvasItem, flame: float = 0.0) -> void:
	# Tüpleri birleştiren sırt çerçevesi (arkada).
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(Rect2(-6.0, -12.0, 12.0, 18.0), 3.0),
			FRAME, OUTLINE_WIDTH)
	for side: float in [-1.0, 1.0]:
		_draw_tank(canvas, side * TANK_OFFSET_X, flame)


static func _draw_tank(canvas: CanvasItem, center_x: float, flame: float) -> void:
	var left: float = center_x - TANK_SIZE.x * 0.5
	var bottom: float = TANK_TOP + TANK_SIZE.y
	if flame > 0.0:
		_draw_flame(canvas, Vector2(center_x, bottom + NOZZLE_HEIGHT - 1.0), flame)
	# Meme: aşağı doğru genişleyen koyu huni.
	PlatformDraw.shape(canvas, PackedVector2Array([
		Vector2(center_x - 3.5, bottom - 1.0), Vector2(center_x + 3.5, bottom - 1.0),
		Vector2(center_x + 6.0, bottom + NOZZLE_HEIGHT), Vector2(center_x - 6.0, bottom + NOZZLE_HEIGHT),
	]), NOZZLE, OUTLINE_WIDTH)
	var body := Rect2(left, TANK_TOP, TANK_SIZE.x, TANK_SIZE.y)
	var radius: float = TANK_SIZE.x * 0.5
	PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(body, radius, 6), BODY)
	# Altın burun (üst kubbe) ve krem bant.
	var cap: PackedVector2Array = PlatformDraw.arc(Vector2(center_x, TANK_TOP + radius), radius - 0.1,
			PI, TAU, 10)
	canvas.draw_colored_polygon(cap, CAP)
	canvas.draw_rect(Rect2(left, TANK_TOP + 15.0, TANK_SIZE.x, 5.0), BAND)
	# Sol kenarda ince parlaklık şeridi (yuvarlak hacim hissi).
	canvas.draw_line(Vector2(left + 3.5, TANK_TOP + 9.0), Vector2(left + 3.5, bottom - 7.0),
			Color(1.0, 1.0, 1.0, 0.35), 2.0, true)
	PlatformDraw.outline(canvas, PlatformDraw.rounded_rect(body, radius, 6), OUTLINE_WIDTH)


## Memeden aşağı uzanan damla biçimli alev: dışı turuncu, içi açık sarı.
static func _draw_flame(canvas: CanvasItem, top: Vector2, flame: float) -> void:
	var length: float = FLAME_LENGTH * flame
	canvas.draw_colored_polygon(_flame_points(top, 5.0, length), FLAME_OUTER)
	canvas.draw_colored_polygon(_flame_points(top, 2.6, length * 0.6), FLAME_INNER)


static func _flame_points(top: Vector2, half_width: float, length: float) -> PackedVector2Array:
	return PackedVector2Array([
		top + Vector2(-half_width, 0.0), top + Vector2(half_width, 0.0),
		top + Vector2(half_width * 0.6, length * 0.55), top + Vector2(0.0, length),
		top + Vector2(-half_width * 0.6, length * 0.55),
	])
