class_name JetpackModel
extends Node3D
## Karakterin sırtına takılan 3D roket: hazır şekillerden (kapsül, silindir, kutu) kodla kurulur,
## karakterle aynı çizgi film gölgelemesi + dış çizgi. CharacterModel bunu göğüs kemiğine bağlar.
## Renkler 2D çizimle ortak (JetpackArt). Ölçüler model biriminde (karakter ≈ 1 birim boyunda);
## orijin iki tüpün ortası, +Y yukarı, +Z karakterin önü.

const FLAT_SHADER: Shader = preload("res://assets/shaders/toon_flat.gdshader")
const OUTLINE_SHADER: Shader = preload("res://assets/shaders/toon_outline.gdshader")

const TANK_RADIUS: float = 0.082
const TANK_HEIGHT: float = 0.36
## Tüp merkezlerinin ortadan uzaklığı.
const TANK_OFFSET_X: float = 0.098
const BAND_HEIGHT: float = 0.055
const NOZZLE_HEIGHT: float = 0.07
const NOZZLE_TOP_RADIUS: float = 0.036
const NOZZLE_BOTTOM_RADIUS: float = 0.066
const FRAME_SIZE := Vector3(0.14, 0.18, 0.07)
## Takılırken/çıkarken büyüyüp küçülme süresi (s).
const POP_TIME: float = 0.16

var _pop: Tween


func _ready() -> void:
	_add_part(_box(FRAME_SIZE), JetpackArt.FRAME, Vector3(0.0, 0.0, 0.03))
	for side: float in [-1.0, 1.0]:
		var x: float = side * TANK_OFFSET_X
		_add_part(_capsule(TANK_RADIUS, TANK_HEIGHT), JetpackArt.BODY, Vector3(x, 0.0, 0.0))
		# Altın burun: tüpün üst kubbesini saran biraz büyük yarım küre.
		_add_part(_dome(TANK_RADIUS * 1.04), JetpackArt.CAP,
				Vector3(x, TANK_HEIGHT * 0.5 - TANK_RADIUS, 0.0))
		_add_part(_cylinder(TANK_RADIUS * 1.05, TANK_RADIUS * 1.05, BAND_HEIGHT), JetpackArt.BAND,
				Vector3(x, 0.0, 0.0))
		_add_part(_cylinder(NOZZLE_TOP_RADIUS, NOZZLE_BOTTOM_RADIUS, NOZZLE_HEIGHT), JetpackArt.NOZZLE,
				Vector3(x, -TANK_HEIGHT * 0.5 - NOZZLE_HEIGHT * 0.35, 0.0))
	visible = false
	scale = Vector3.ONE * 0.001


## Roketi gösterir/gizler: küçükten büyüyerek takılır, küçülerek kaybolur.
func set_equipped(equipped: bool) -> void:
	if _pop != null:
		_pop.kill()
	_pop = create_tween()
	if equipped:
		visible = true
		_pop.tween_property(self, ^"scale", Vector3.ONE, POP_TIME) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_pop.tween_property(self, ^"scale", Vector3.ONE * 0.001, POP_TIME * 0.6)
		_pop.tween_callback(hide)


func _add_part(mesh: Mesh, color: Color, at: Vector3) -> void:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter(&"outline_color", Tuning.MODEL_OUTLINE_COLOR)
	outline.set_shader_parameter(&"outline_width", Tuning.MODEL_OUTLINE_WIDTH)
	var material := ShaderMaterial.new()
	material.shader = FLAT_SHADER
	material.set_shader_parameter(&"base_color", color)
	material.set_shader_parameter(&"rim_color", Tuning.MODEL_RIM_COLOR)
	material.set_shader_parameter(&"rim_strength", Tuning.MODEL_RIM_STRENGTH)
	material.set_shader_parameter(&"shadow_tint", Tuning.MODEL_SHADOW_TINT)
	material.next_pass = outline
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = at
	add_child(part)


func _capsule(radius: float, height: float) -> CapsuleMesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	return mesh


func _dome(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius
	mesh.is_hemisphere = true
	return mesh


func _cylinder(top_radius: float, bottom_radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	return mesh


func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh
