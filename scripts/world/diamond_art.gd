class_name DiamondArt
extends RefCounted
## Elmasın (para) 2D çizimi ve ortak renkleri: kesme taş biçimi (üstte düz tabla, ortada kuşak, altta sivri uç).
## Toplanabilir nesne, HUD, menü ve oyun sonu ekranı bunu çizer. Orijin taşın ortasında.

## Açık buz mavisi yüzeyler, koyu mavi gölge yüzü, beyaz parıltı.
const LIGHT := Color(0.78, 0.97, 1.0)
const MID := Color(0.42, 0.82, 0.99)
const DARK := Color(0.22, 0.52, 0.92)
const GLOW := Color(0.45, 0.85, 1.0)

## Ölçek 1'de taşın yarı genişliği (kuşak), tablanın yarı genişliği ve dikey ölçüleri (px).
const HALF_WIDTH: float = 14.0
const TABLE_HALF: float = 7.0
const TOP: float = -10.0
const GIRDLE: float = -3.0
const TIP: float = 14.0
const OUTLINE_WIDTH: float = 2.0


## scale: 1 = toplanabilir boyutu (~28 x 24 px); arayüz simgeleri için küçültülür.
static func draw(canvas: CanvasItem, center: Vector2 = Vector2.ZERO, scale: float = 1.0) -> void:
	var p := func(x: float, y: float) -> Vector2: return center + Vector2(x, y) * scale
	var left: Vector2 = p.call(-HALF_WIDTH, GIRDLE)
	var right: Vector2 = p.call(HALF_WIDTH, GIRDLE)
	var table_left: Vector2 = p.call(-TABLE_HALF, TOP)
	var table_right: Vector2 = p.call(TABLE_HALF, TOP)
	var inner_left: Vector2 = p.call(-TABLE_HALF * 0.45, GIRDLE)
	var inner_right: Vector2 = p.call(TABLE_HALF * 0.45, GIRDLE)
	var tip: Vector2 = p.call(0.0, TIP)
	# Taç (üst yarı): yan yüzler orta ton, tabla açık.
	canvas.draw_colored_polygon(PackedVector2Array([left, table_left, inner_left]), MID)
	canvas.draw_colored_polygon(PackedVector2Array([table_left, table_right, inner_right, inner_left]), LIGHT)
	canvas.draw_colored_polygon(PackedVector2Array([table_right, right, inner_right]), PlatformDraw.tone(MID, 0.25))
	# Taban (alt yarı): soldan sağa koyulaşan üç yüz (ışık soldan-üstten).
	canvas.draw_colored_polygon(PackedVector2Array([left, inner_left, tip]), MID)
	canvas.draw_colored_polygon(PackedVector2Array([inner_left, inner_right, tip]), PlatformDraw.tone(LIGHT, -0.08))
	canvas.draw_colored_polygon(PackedVector2Array([inner_right, right, tip]), DARK)
	# Tablada küçük beyaz parıltı.
	canvas.draw_line(p.call(-TABLE_HALF * 0.55, TOP + 2.2), p.call(-TABLE_HALF * 0.05, TOP + 2.2),
			Color(1.0, 1.0, 1.0, 0.85), maxf(1.6 * scale, 1.0), true)
	PlatformDraw.outline(canvas, PackedVector2Array([table_left, table_right, right, tip, left]),
			maxf(OUTLINE_WIDTH * scale, 1.0))
