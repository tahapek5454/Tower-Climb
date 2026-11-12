class_name Backdrop
extends Node2D
## Kule dışı arka plan (gökyüzü, tepeler, bulutlar; assets/shaders/backdrop.gdshader).
## Ekranı kaplayan tek dikdörtgen kamerayı takip eder; parallax shader'da hesaplanır.
## Sahnede en arkada olmalı (main.gd'de ilk eklenir). Gökyüzü/bulut/dağ renkleri temadan gelir.

const SHADER: Shader = preload("res://assets/shaders/backdrop.gdshader")

var _rect: Polygon2D
var _material: ShaderMaterial
var _theme := ThemeTracker.new()


func _ready() -> void:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter(&"meadow_color", WorldPalette.MEADOW)
	material.set_shader_parameter(&"meadow_light_color", WorldPalette.MEADOW_LIGHT)
	material.set_shader_parameter(&"meadow_dark_color", WorldPalette.MEADOW_DARK)
	material.set_shader_parameter(&"view_height", Tuning.VIEW_HEIGHT)
	material.set_shader_parameter(&"rest_top", Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT)
	material.set_shader_parameter(&"ground_view_y", Tuning.VIEW_HEIGHT - Tuning.GROUND_SCREEN_MARGIN)
	material.set_shader_parameter(&"hill_far_factor", Tuning.BACKDROP_HILL_FAR_PARALLAX)
	material.set_shader_parameter(&"hill_near_factor", Tuning.BACKDROP_HILL_NEAR_PARALLAX)
	material.set_shader_parameter(&"cloud_far_factor", Tuning.BACKDROP_CLOUD_FAR_PARALLAX)
	material.set_shader_parameter(&"cloud_near_factor", Tuning.BACKDROP_CLOUD_NEAR_PARALLAX)
	material.set_shader_parameter(&"cloud_drift_speed", Tuning.BACKDROP_CLOUD_DRIFT_SPEED)

	# Sarsıntı ve bir karelik takip gecikmesi için her yönde pay.
	var margin: float = Tuning.SHAKE_MAX_OFFSET + Tuning.CAMERA_MAX_SPEED
	_rect = Tower.make_rect_visual(
			Vector2(Tuning.VIEW_WIDTH, Tuning.VIEW_HEIGHT) + Vector2.ONE * margin * 2.0, Color.WHITE)
	_rect.name = "Sky"
	_rect.material = material
	add_child(_rect)
	_material = material
	_apply_theme()


func _process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		_rect.position = camera.get_screen_center_position()
		if _theme.update(camera.get_screen_center_position().y):
			_apply_theme()


func _apply_theme() -> void:
	var colors: Dictionary = _theme.colors
	_material.set_shader_parameter(&"sky_top", colors[&"sky_top"])
	_material.set_shader_parameter(&"sky_bottom", colors[&"sky_bottom"])
	_material.set_shader_parameter(&"hill_far_color", colors[&"hill_far"])
	_material.set_shader_parameter(&"hill_near_color", colors[&"hill_near"])
	_material.set_shader_parameter(&"cloud_color", colors[&"cloud"])
	_material.set_shader_parameter(&"cloud_shade_color", colors[&"cloud_shade"])
