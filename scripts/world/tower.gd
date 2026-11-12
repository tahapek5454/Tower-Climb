class_name Tower
extends Node2D
## Kule: sol/sağ duvarlar ve zemin. Dünya orijini: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y.
## Duvarlar kamerayı dikeyde takip eder; böylece kule sonsuz görünür.
## Desenler shader'da dünya koordinatından hesaplanır: duvar kamerayla kaysa da taşlar yerinde durur.
## Renkler temadan gelir (ThemeTracker): kamera yükseldikçe bölüm temaları arasında yumuşak geçiş.

const INTERIOR_SHADER: Shader = preload("res://assets/shaders/tower_interior.gdshader")
const WALL_SHADER: Shader = preload("res://assets/shaders/tower_wall.gdshader")

var _walls: Node2D
var _interior_material: ShaderMaterial
var _wall_materials: Array[ShaderMaterial] = []
var _theme := ThemeTracker.new()


func _ready() -> void:
	_walls = Node2D.new()
	_walls.name = "Walls"
	add_child(_walls)

	_walls.add_child(_make_interior())

	var wall_x: float = (Tuning.TOWER_WIDTH + Tuning.WALL_THICKNESS) * 0.5
	_walls.add_child(_make_wall("LeftWall", -wall_x, 1.0))
	_walls.add_child(_make_wall("RightWall", wall_x, -1.0))

	add_child(_make_ground())
	_apply_theme()


func _physics_process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		_walls.position.y = camera.get_screen_center_position().y


func _process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null and _theme.update(camera.get_screen_center_position().y):
		_apply_theme()


## Geçerli tema renklerini arka duvar ve yan duvar shader'larına yazar.
func _apply_theme() -> void:
	var colors: Dictionary = _theme.colors
	_interior_material.set_shader_parameter(&"stone_color", colors[&"interior_stone"])
	_interior_material.set_shader_parameter(&"joint_color", colors[&"interior_joint"])
	for material: ShaderMaterial in _wall_materials:
		material.set_shader_parameter(&"wall_color", colors[&"wall"])
		material.set_shader_parameter(&"joint_color", colors[&"wall_joint"])
		material.set_shader_parameter(&"lip_color", colors[&"wall_lip"])


## Arka duvar: taş deseni shader ile çizilir.
func _make_interior() -> Polygon2D:
	var material := ShaderMaterial.new()
	material.shader = INTERIOR_SHADER
	material.set_shader_parameter(&"block_size", Tuning.INTERIOR_BLOCK_SIZE)
	material.set_shader_parameter(&"corner_radius", Tuning.INTERIOR_BLOCK_CORNER_RADIUS)
	material.set_shader_parameter(&"joint_width", Tuning.INTERIOR_JOINT_WIDTH)
	material.set_shader_parameter(&"joint_softness", Tuning.INTERIOR_JOINT_SOFTNESS)
	material.set_shader_parameter(&"block_variation", Tuning.INTERIOR_BLOCK_VARIATION)
	material.set_shader_parameter(&"bevel_strength", Tuning.INTERIOR_BEVEL_STRENGTH)
	material.set_shader_parameter(&"half_width", Tuning.TOWER_WIDTH * 0.5)
	material.set_shader_parameter(&"edge_shade_width", Tuning.INTERIOR_EDGE_SHADE_WIDTH)
	material.set_shader_parameter(&"edge_shade_strength", Tuning.INTERIOR_EDGE_SHADE_STRENGTH)
	material.set_shader_parameter(&"parallax_factor", Tuning.INTERIOR_PARALLAX)
	material.set_shader_parameter(&"rest_top", Tuning.GROUND_SCREEN_MARGIN - Tuning.VIEW_HEIGHT)

	var interior_size := Vector2(Tuning.TOWER_WIDTH, Tuning.WALL_HEIGHT)
	var interior: Polygon2D = make_rect_visual(interior_size, Color.WHITE)
	interior.name = "Interior"
	interior.material = material
	_interior_material = material
	return interior


## Yan duvar: çarpışma gövdesi + taş sütun görünümü.
## inner_sign: kule içi duvarın sağındaysa +1 (sol duvar), solundaysa -1 (sağ duvar).
func _make_wall(wall_name: String, center_x: float, inner_sign: float) -> StaticBody2D:
	var material := ShaderMaterial.new()
	material.shader = WALL_SHADER
	material.set_shader_parameter(&"center_x", center_x)
	material.set_shader_parameter(&"thickness", Tuning.WALL_THICKNESS)
	material.set_shader_parameter(&"inner_sign", inner_sign)
	material.set_shader_parameter(&"segment_height", Tuning.WALL_SEGMENT_HEIGHT)
	material.set_shader_parameter(&"joint_width", Tuning.WALL_JOINT_WIDTH)
	material.set_shader_parameter(&"lip_width", Tuning.WALL_LIP_WIDTH)
	material.set_shader_parameter(&"outer_shade", Tuning.WALL_OUTER_SHADE)

	var size := Vector2(Tuning.WALL_THICKNESS, Tuning.WALL_HEIGHT)
	var body: StaticBody2D = _make_body(wall_name, Vector2(center_x, 0.0), size)
	var visual: Polygon2D = make_rect_visual(size, Color.WHITE)
	visual.material = material
	_wall_materials.append(material)
	body.add_child(visual)
	return body


## Zemin: çarpışma gövdesi ince bir levha; görüntü ekranın altına kadar inen dolu bir taban.
func _make_ground() -> StaticBody2D:
	var slab_size := Vector2(Tuning.TOWER_WIDTH, Tuning.PLATFORM_THICKNESS)
	var body: StaticBody2D = _make_body("Ground", Vector2(0.0, slab_size.y * 0.5), slab_size)

	var base_size := Vector2(Tuning.TOWER_WIDTH, Tuning.GROUND_VISUAL_DEPTH)
	var base: Polygon2D = make_rect_visual(base_size, WorldPalette.GROUND_BASE)
	base.position.y = (base_size.y - slab_size.y) * 0.5
	body.add_child(base)

	body.add_child(make_rect_visual(slab_size, WorldPalette.GROUND))

	var top_size := Vector2(Tuning.TOWER_WIDTH, Tuning.GROUND_TOP_HEIGHT)
	var top: Polygon2D = make_rect_visual(top_size, WorldPalette.GROUND_TOP)
	top.position.y = (top_size.y - slab_size.y) * 0.5
	body.add_child(top)
	return body


## Ortalanmış dikdörtgen çarpışma gövdesi (görselsiz).
func _make_body(body_name: String, pos: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = pos

	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	return body


## Orijinde ortalanmış düz renkli dikdörtgen.
static func make_rect_visual(size: Vector2, color: Color) -> Polygon2D:
	var half: Vector2 = size * 0.5
	var polygon := Polygon2D.new()
	polygon.color = color
	polygon.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	return polygon
