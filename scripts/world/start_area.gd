class_name StartArea
extends Node2D
## Kulenin dibindeki başlangıç alanı (sadece görüntü): duvar diplerinde sandıklar, fıçı, yukarıyı
## gösteren tabela, iki yanda yanan mangallar, çimen ve çiçek öbekleri. Zeminle aynı derinlikte
## (dünya koordinatı, parallax yok). Orijin zeminin üst yüzeyinin ortası (y = 0).
## Oyuncu ortada başlar; süsler duvarlara yakın ve alçak, yolu kapatmaz.

const CRATE := Color(0.55, 0.42, 0.30)
const BARREL := Color(0.50, 0.36, 0.27)
const SIGN := Color(0.62, 0.50, 0.36)

var _time: float = 0.0
var _glow: PlatformGlow


func _ready() -> void:
	_glow = PlatformGlow.new()
	_glow.name = "Glow"
	add_child(_glow)
	var half: float = Tuning.TOWER_WIDTH * 0.5
	var flames: Array = []
	for x: float in _brazier_positions(half):
		flames.append([Vector2(x, -38.0), Tuning.LIGHT_TORCH_SIZE * 1.3,
				Color(WallDecorArt.FLAME_OUTER, Tuning.LIGHT_TORCH_ALPHA)])
	_glow.set_lights(flames, true, 1.7)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var half: float = Tuning.TOWER_WIDTH * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = 2024
	_grass_strip(-half + 6.0, -half + 210.0, rng)
	_grass_strip(half - 210.0, half - 6.0, rng)
	_crate(Rect2(-half + 18.0, -40.0, 40.0, 40.0))
	_crate(Rect2(-half + 26.0, -72.0, 30.0, 32.0))
	_barrel(Vector2(-half + 82.0, 0.0))
	_sign(Vector2(half - 52.0, 0.0))
	for i: int in 2:
		_brazier(Vector2(_brazier_positions(half)[i], 0.0), float(i) * 2.1)


func _brazier_positions(half: float) -> Array[float]:
	return [-half + 140.0, half - 120.0]


func _crate(rect: Rect2) -> void:
	var body := PlatformDraw.rounded_rect(rect, 3.0)
	PlatformDraw.shape(self, body, CRATE)
	var inner := rect.grow(-5.0)
	draw_rect(inner, CRATE.darkened(0.15))
	draw_line(inner.position, inner.end, CRATE.lightened(0.1), 4.0, true)
	draw_line(Vector2(inner.position.x, inner.end.y), Vector2(inner.end.x, inner.position.y),
			CRATE.lightened(0.1), 4.0, true)
	PlatformDraw.outline(self, PlatformDraw.rounded_rect(inner, 1.0), 1.0)
	PlatformDraw.outline(self, body, 1.6)


func _barrel(base: Vector2) -> void:
	var rect := Rect2(base + Vector2(-15.0, -40.0), Vector2(30.0, 40.0))
	var body := PlatformDraw.rounded_rect(rect, 9.0)
	PlatformDraw.shape(self, body, BARREL)
	draw_rect(Rect2(rect.position + Vector2(5.0, 3.0), Vector2(5.0, 34.0)), BARREL.lightened(0.15))
	for y: float in [8.0, 32.0]:
		draw_line(Vector2(rect.position.x + 1.0, rect.position.y + y), Vector2(rect.end.x - 1.0,
				rect.position.y + y), WallDecorArt.IRON, 3.0, true)
	PlatformDraw.outline(self, body, 1.6)


## Yukarıyı gösteren tabela: direk + ok biçimli levha.
func _sign(base: Vector2) -> void:
	var post := PlatformDraw.rounded_rect(Rect2(base + Vector2(-3.0, -62.0), Vector2(6.0, 62.0)), 2.0)
	PlatformDraw.shape(self, post, WallDecorArt.WOOD, 1.4)
	var top: Vector2 = base + Vector2(0.0, -96.0)
	var arrow := PackedVector2Array([top, top + Vector2(20.0, 18.0), top + Vector2(9.0, 18.0),
			top + Vector2(9.0, 40.0), top + Vector2(-9.0, 40.0), top + Vector2(-9.0, 18.0),
			top + Vector2(-20.0, 18.0)])
	PlatformDraw.shape(self, arrow, SIGN, 1.8)
	draw_line(top + Vector2(0.0, 12.0), top + Vector2(0.0, 34.0), SIGN.lightened(0.25), 3.0, true)


## Mangal: kısa ayaklar üstünde demir kâse ve yanan alev.
func _brazier(base: Vector2, phase: float) -> void:
	for side: float in [-1.0, 1.0]:
		draw_line(base + Vector2(8.0 * side, 0.0), base + Vector2(5.0 * side, -16.0), WallDecorArt.OUTLINE, 4.0, true)
		draw_line(base + Vector2(8.0 * side, 0.0), base + Vector2(5.0 * side, -16.0), WallDecorArt.IRON, 2.4, true)
	var bowl := PackedVector2Array([base + Vector2(-17.0, -28.0), base + Vector2(17.0, -28.0),
			base + Vector2(10.0, -15.0), base + Vector2(-10.0, -15.0)])
	var sway: float = sin(_time * 8.0 + phase) * 0.6 + sin(_time * 12.3 + phase) * 0.4
	WallDecorArt._flame(self, base + Vector2(0.0, -26.0), 22.0, 30.0 + sway * 4.0, sway)
	PlatformDraw.shape(self, bowl, WallDecorArt.IRON, 1.6)
	draw_line(base + Vector2(-15.0, -25.0), base + Vector2(15.0, -25.0), WallDecorArt.IRON.lightened(0.25), 2.0, true)


func _grass_strip(from_x: float, to_x: float, rng: RandomNumberGenerator) -> void:
	var x: float = from_x
	while x < to_x:
		if rng.randf() < 0.3:
			PlatformDecor._flower(self, Vector2(x, 0.5), rng)
		else:
			PlatformDecor._grass(self, Vector2(x, 0.5), rng)
		x += rng.randf_range(14.0, 30.0)
