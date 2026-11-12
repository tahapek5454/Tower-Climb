class_name WallDecorRules
extends RefCounted
## Kule iç duvarı süslerinin yerleşim kuralları (saf). Duvar, yukarı doğru eşit aralıklı "yuvalara"
## bölünür; her yuvada kata bağlı sabit bir rastgelelikle süs olup olmadığı, türü ve konumu seçilir.
## Koordinatlar "duvar uzayında" (arka duvar deseniyle aynı; parallax WallDecor'da uygulanır).

## Temalara göre süs türleri (WorldPalette tema sırasıyla).
const THEME_ITEMS: Array[Array] = [
	[&"torch", &"window", &"banner", &"bunting"],
	[&"torch", &"banner", &"bunting", &"window"],
	[&"torch", &"banner", &"bunting", &"window"],
	[&"window", &"banner", &"torch"],
	[&"window", &"banner", &"bunting"],
]


## Yuvanın duvar uzayındaki y'si (yukarı = -y).
static func slot_y(slot: int) -> float:
	return -float(slot) * Tuning.WALL_DECOR_SPACING - Tuning.WALL_DECOR_START_HEIGHT


## y aralığına (üst < alt) düşen yuvalar: Vector2i(ilk, son), ilk > son ise boş.
static func slots_between(top_y: float, bottom_y: float) -> Vector2i:
	var first: int = maxi(0, ceili(-(bottom_y + Tuning.WALL_DECOR_START_HEIGHT) / Tuning.WALL_DECOR_SPACING))
	var last: int = floori(-(top_y + Tuning.WALL_DECOR_START_HEIGHT) / Tuning.WALL_DECOR_SPACING)
	return Vector2i(first, last)


## Duvar uzayındaki y'nin, süs ekrandayken denk geldiği dünya y'si. Duvar parallax ile yavaş kaydığı
## için duvar uzayı yükseldikçe dünyanın gerisinde kalır; tema bu dünya yüksekliğinden seçilir.
## (Süs ekrandayken görüntünün üst kenarı ≈ süsün dünya y'si varsayımıyla: dünya = desen + (dünya - başlangıç)(1 - p).)
static func world_y_of(wall_y: float) -> float:
	var factor: float = Tuning.INTERIOR_PARALLAX
	var rest_top: float = Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT
	return (wall_y - rest_top * (1.0 - factor)) / factor


## Yuvanın süsü: {} (boş) ya da {kind, x, y, theme, seed, span}. span sadece flama dizisinde
## (iki ucu arası genişlik); diğerlerinde 0. Süs kule iç genişliğinin dışına taşmaz.
static func slot_item(slot: int) -> Dictionary:
	if slot < 0:
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(slot * 92821 + 5)
	if rng.randf() >= Tuning.WALL_DECOR_CHANCE:
		return {}
	var y: float = slot_y(slot)
	var theme: int = ThemeRules.platform_theme(floori(ThemeRules.floor_value_at(world_y_of(y))))
	var kinds: Array = THEME_ITEMS[theme]
	var kind: StringName = kinds[rng.randi_range(0, kinds.size() - 1)]
	var half: float = Tuning.TOWER_WIDTH * 0.5 - Tuning.WALL_DECOR_MARGIN
	var x: float = rng.randf_range(-half, half)
	var span: float = 0.0
	if kind == &"bunting":
		span = rng.randf_range(0.3, 0.6) * Tuning.TOWER_WIDTH
		var limit: float = Tuning.TOWER_WIDTH * 0.5 - span * 0.5 - Tuning.WALL_DECOR_MARGIN * 0.5
		x = clampf(x, -limit, limit)
	return {&"kind": kind, &"x": x, &"y": y, &"theme": theme, &"seed": slot, &"span": span}
