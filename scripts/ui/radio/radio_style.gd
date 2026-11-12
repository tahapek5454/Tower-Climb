class_name RadioStyle
extends RefCounted
## Radyo panelinin renkleri ve ikon çizimleri (ortak). Dünya paletiyle uyumlu: koyu arduvaz zemin,
## soluk turkuaz vurgu; neon/parlak renk yok.

const PANEL := Color(0.09, 0.10, 0.15, 0.85)
const BORDER := Color(0.40, 0.66, 0.68, 0.45)
const TEXT := Color(0.88, 0.90, 0.95)
const TEXT_DIM := Color(0.60, 0.65, 0.76)
const ACCENT := Color(0.42, 0.74, 0.76)
const ACCENT_DARK := Color(0.08, 0.12, 0.16)
const TRACK := Color(1.0, 1.0, 1.0, 0.14)
const DISABLED := Color(0.45, 0.48, 0.56, 0.6)


## İkon çizer (merkez, boyut px). kind: prev, next, play, pause, volume, volume_off, note, folder, add,
## sfx, sfx_off.
static func icon(canvas: CanvasItem, kind: StringName, center: Vector2, size: float, color: Color) -> void:
	var s: float = size * 0.5
	match kind:
		&"play":
			canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(-s * 0.55, -s * 0.75),
					center + Vector2(s * 0.8, 0.0), center + Vector2(-s * 0.55, s * 0.75)]), color)
		&"pause":
			for side: float in [-1.0, 1.0]:
				canvas.draw_rect(Rect2(center + Vector2(side * s * 0.38 - s * 0.18, -s * 0.7),
						Vector2(s * 0.36, s * 1.4)), color)
		&"prev", &"next":
			var dir: float = 1.0 if kind == &"next" else -1.0
			canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(-s * 0.6 * dir, -s * 0.65),
					center + Vector2(s * 0.45 * dir, 0.0), center + Vector2(-s * 0.6 * dir, s * 0.65)]), color)
			canvas.draw_rect(Rect2(center + Vector2(s * 0.45 * dir - (s * 0.22 if dir > 0.0 else 0.0), -s * 0.65),
					Vector2(s * 0.22, s * 1.3)), color)
		&"volume", &"volume_off", &"sfx", &"sfx_off":
			_speaker(canvas, center, s, color, kind)
		&"note":
			canvas.draw_circle(center + Vector2(-s * 0.3, s * 0.45), s * 0.32, color, true, -1.0, true)
			canvas.draw_line(center + Vector2(0.0, s * 0.45), center + Vector2(0.0, -s * 0.7), color, s * 0.18, true)
			canvas.draw_line(center + Vector2(0.0, -s * 0.7), center + Vector2(s * 0.55, -s * 0.4), color, s * 0.18, true)
		&"folder":
			canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(-s * 0.8, -s * 0.55),
					center + Vector2(-s * 0.2, -s * 0.55), center + Vector2(0.0, -s * 0.35),
					center + Vector2(s * 0.8, -s * 0.35), center + Vector2(s * 0.8, s * 0.6),
					center + Vector2(-s * 0.8, s * 0.6)]), color)
		&"add":
			canvas.draw_line(center + Vector2(-s * 0.7, 0.0), center + Vector2(s * 0.7, 0.0), color, s * 0.25, true)
			canvas.draw_line(center + Vector2(0.0, -s * 0.7), center + Vector2(0.0, s * 0.7), color, s * 0.25, true)


## Hoparlör; ses dalgası (açık) ya da çarpı (kapalı). sfx türünde dalga yerine küçük yıldız.
static func _speaker(canvas: CanvasItem, center: Vector2, s: float, color: Color, kind: StringName) -> void:
	var base: Vector2 = center + Vector2(-s * 0.35, 0.0)
	canvas.draw_colored_polygon(PackedVector2Array([base + Vector2(-s * 0.45, -s * 0.25),
			base + Vector2(-s * 0.15, -s * 0.25), base + Vector2(s * 0.25, -s * 0.6),
			base + Vector2(s * 0.25, s * 0.6), base + Vector2(-s * 0.15, s * 0.25),
			base + Vector2(-s * 0.45, s * 0.25)]), color)
	var right: Vector2 = center + Vector2(s * 0.45, 0.0)
	if kind == &"volume_off" or kind == &"sfx_off":
		var r: float = s * 0.3
		canvas.draw_line(right + Vector2(-r, -r), right + Vector2(r, r), color, s * 0.16, true)
		canvas.draw_line(right + Vector2(-r, r), right + Vector2(r, -r), color, s * 0.16, true)
	elif kind == &"sfx":
		PlatformDraw.sparkle(canvas, right, s * 0.42, color)
	else:
		canvas.draw_arc(center + Vector2(s * 0.05, 0.0), s * 0.45, -0.9, 0.9, 8, color, s * 0.14, true)
		canvas.draw_arc(center + Vector2(s * 0.05, 0.0), s * 0.75, -0.9, 0.9, 10, color, s * 0.14, true)
