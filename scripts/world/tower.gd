class_name Tower
extends Node2D
## Kule: sol/sağ duvarlar ve zemin. Dünya orijini: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y.
## Duvarlar kamerayı dikeyde takip eder; böylece kule sonsuz görünür.

const INTERIOR_SHADER: Shader = preload("res://assets/shaders/tower_interior.gdshader")

var _walls: Node2D


func _ready() -> void:
	_walls = Node2D.new()
	_walls.name = "Walls"
	add_child(_walls)

	_walls.add_child(_make_interior())

	var wall_size := Vector2(Tuning.WALL_THICKNESS, Tuning.WALL_HEIGHT)
	var wall_x: float = (Tuning.TOWER_WIDTH + Tuning.WALL_THICKNESS) * 0.5
	_walls.add_child(_make_body("LeftWall", Vector2(-wall_x, 0.0), wall_size, WorldPalette.WALL))
	_walls.add_child(_make_body("RightWall", Vector2(wall_x, 0.0), wall_size, WorldPalette.WALL))

	var ground_size := Vector2(Tuning.TOWER_WIDTH, Tuning.PLATFORM_THICKNESS)
	var ground_pos := Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	add_child(_make_body("Ground", ground_pos, ground_size, WorldPalette.GROUND))


## Arka duvar: taş deseni shader ile çizilir (desen dünya koordinatında sabit).
func _make_interior() -> Polygon2D:
	var material := ShaderMaterial.new()
	material.shader = INTERIOR_SHADER
	material.set_shader_parameter(&"stone_color", WorldPalette.INTERIOR_STONE)
	material.set_shader_parameter(&"joint_color", WorldPalette.INTERIOR_JOINT)
	material.set_shader_parameter(&"block_size", Tuning.INTERIOR_BLOCK_SIZE)
	material.set_shader_parameter(&"corner_radius", Tuning.INTERIOR_BLOCK_CORNER_RADIUS)
	material.set_shader_parameter(&"joint_width", Tuning.INTERIOR_JOINT_WIDTH)
	material.set_shader_parameter(&"joint_softness", Tuning.INTERIOR_JOINT_SOFTNESS)
	material.set_shader_parameter(&"block_variation", Tuning.INTERIOR_BLOCK_VARIATION)
	material.set_shader_parameter(&"bevel_strength", Tuning.INTERIOR_BEVEL_STRENGTH)
	material.set_shader_parameter(&"half_width", Tuning.TOWER_WIDTH * 0.5)
	material.set_shader_parameter(&"edge_shade_width", Tuning.INTERIOR_EDGE_SHADE_WIDTH)
	material.set_shader_parameter(&"edge_shade_strength", Tuning.INTERIOR_EDGE_SHADE_STRENGTH)

	var interior_size := Vector2(Tuning.TOWER_WIDTH, Tuning.WALL_HEIGHT)
	var interior: Polygon2D = make_rect_visual(interior_size, Color.WHITE)
	interior.name = "Interior"
	interior.material = material
	return interior


func _physics_process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		_walls.position.y = camera.get_screen_center_position().y


## Ortalanmış dikdörtgen çarpışma gövdesi + görseli.
func _make_body(body_name: String, pos: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = pos

	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)

	body.add_child(make_rect_visual(size, color))
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
