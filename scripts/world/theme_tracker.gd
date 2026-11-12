class_name ThemeTracker
extends RefCounted
## Kameranın yüksekliğinden geçerli tema renklerini izler. Renkler sadece tema konumu değişince
## yeniden hesaplanır; kullanan düğüm update() true dönünce shader parametrelerini günceller.

var colors: Dictionary = WorldPalette.colors_at(0.0)
var theme_position: float = 0.0
var _initialized: bool = false


## Kamera merkezinin dünya y'sine göre günceller; renkler değiştiyse true.
func update(camera_center_y: float) -> bool:
	var new_position: float = ThemeRules.position(ThemeRules.floor_value_at(camera_center_y))
	if _initialized and is_equal_approx(new_position, theme_position):
		return false
	_initialized = true
	theme_position = new_position
	colors = WorldPalette.colors_at(theme_position)
	return true
