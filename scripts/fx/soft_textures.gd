class_name SoftTextures
extends RefCounted
## Kodla üretilen paylaşılan dokular ve malzemeler (dış dosya yok). İlk istekte bir kez oluşturulur.

## Yumuşak daire dokusunun boyutu (px).
const DOT_SIZE: int = 64

static var _dot: Texture2D
static var _additive: CanvasItemMaterial


## Ortası opak, kenara doğru tamamen saydam beyaz daire (parçacık ve ışık hâlesi için).
static func dot() -> Texture2D:
	if _dot == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
		gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = DOT_SIZE
		texture.height = DOT_SIZE
		_dot = texture
	return _dot


## Toplamalı karışım: altındaki renge eklenir → karanlık zeminde ışık gibi parlar.
static func additive() -> CanvasItemMaterial:
	if _additive == null:
		_additive = CanvasItemMaterial.new()
		_additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive
