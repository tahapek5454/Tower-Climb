class_name CharacterModel
extends Node2D
## 3D karakter modelini şeffaf bir SubViewport'ta yandan çizer ve 2D'de bir Sprite2D ile gösterir.
## Orijin modelin ayaklarındadır (PlayerVisual'daki Squash düğümüne takılır).
## Sadece görüntü: hangi animasyonun oynayacağına PlayerVisual karar verir.

const MODEL_PATH: String = "res://assets/models/eagle_hero.glb"
const TOON_SHADER: Shader = preload("res://assets/shaders/toon_character.gdshader")
const OUTLINE_SHADER: Shader = preload("res://assets/shaders/toon_outline.gdshader")
## Döngülü oynaması gereken animasyonlar (glb döngü bilgisini taşımıyor).
const LOOPING: Array[StringName] = [&"idle", &"run", &"fall", &"fly"]
## Kamera modelin yanında, bu uzaklıkta durur (ortografik: uzaklık görüntüyü değiştirmez).
const CAMERA_DISTANCE: float = 5.0
## Sırt roketinin bağlandığı kemik ve dinlenme pozunda model uzayındaki yeri (+Y yukarı, +Z ön).
const JETPACK_BONE: StringName = &"chest"
const JETPACK_POSITION := Vector3(0.0, 0.50, -0.23)
## Şapkanın bağlandığı kemik (şapka orijini model uzayında; accessories.glb'deki dönüşüm aynen kullanılır).
const HAT_BONE: StringName = &"head"

var _pivot: Node3D
var _animation_player: AnimationPlayer
var _jetpack: JetpackModel
var _hat: HatModel
## Karakterin toon malzemeleri (tişört/pantolon boyaması bunlara uygulanır).
var _toon_materials: Array[ShaderMaterial] = []
## Kuşanılan kozmetikler (yuva → kimlik); sahneye girmeden önce verilenler kurulunca uygulanır.
var _cosmetics: Dictionary = {}
var _target_yaw: float = 0.0
var _requested: StringName = &""
var _facing: float = 1.0
var _front_view: bool = false
var _view_angle_degrees: float = Tuning.MODEL_VIEW_ANGLE_DEGREES
## Önizleme (mağaza): açı dışarıdan verilir, yön görünümü yok sayılır.
var _preview_yaw_enabled: bool = false


## Model dosyası projede var mı? Yoksa PlayerVisual kutu gövdeye döner.
static func is_available() -> bool:
	return ResourceLoader.exists(MODEL_PATH)


func _ready() -> void:
	_build()
	set_facing(1.0, true)
	play(&"idle")


func _process(delta: float) -> void:
	var weight: float = 1.0 - exp(-Tuning.MODEL_TURN_RATE * delta)
	_pivot.rotation.y = lerp_angle(_pivot.rotation.y, _target_yaw, weight)


## direction: +1 sağa, -1 sola bakar. Model kameraya doğru hafif dönük durur.
func set_facing(direction: float, instant: bool = false) -> void:
	_facing = 1.0 if direction >= 0.0 else -1.0
	_update_target_yaw()
	if instant:
		_pivot.rotation.y = _target_yaw


## true: model tam kameraya döner (önden görünüm); false: yön görünümüne geri döner.
func set_front_view(enabled: bool) -> void:
	if enabled == _front_view:
		return
	_front_view = enabled
	_update_target_yaw()


## Modelin profilden kameraya dönüklüğü (derece); yön görünümünde kullanılır.
func set_view_angle(degrees: float) -> void:
	if is_equal_approx(degrees, _view_angle_degrees):
		return
	_view_angle_degrees = degrees
	_update_target_yaw()


## Sırt roketini takar / çıkarır (iskelette kemik yoksa yok sayılır).
func set_jetpack_equipped(equipped: bool) -> void:
	if _jetpack != null:
		_jetpack.set_equipped(equipped)


## Kuşanılan kozmetiği uygular (slot: ShopCatalog.HAT / SHIRT / PANTS; item_id: ShopCatalog kimliği).
## Mağaza önizlemesi de bunu çağırır (satın almadan deneme).
func set_cosmetic(slot: StringName, item_id: StringName) -> void:
	_cosmetics[slot] = item_id
	if slot == ShopCatalog.HAT:
		if _hat != null:
			_hat.show_hat(item_id if Tuning.COSMETICS_ENABLED else ShopCatalog.default_of(slot))
		return
	for material in _toon_materials:
		CosmeticPaint.apply(material, slot, item_id)


## Önizleme için modeli verilen açıya çevirir (radyan, Pivot'un Y dönüşü: -PI/2 = tam kameraya dönük,
## 0 = sağa profil). Bir kez çağrılınca set_facing / set_front_view açıyı artık değiştirmez.
func set_preview_yaw(yaw: float, instant: bool = true) -> void:
	_preview_yaw_enabled = true
	_target_yaw = yaw
	if instant:
		_pivot.rotation.y = yaw


func _update_target_yaw() -> void:
	if _preview_yaw_enabled:
		return
	# Model +Z'ye bakar; kamera -X tarafında. Sola dönüş kameranın önünden geçer.
	var view_angle: float = deg_to_rad(_view_angle_degrees)
	if _front_view:
		_target_yaw = -PI * 0.5
	else:
		_target_yaw = -view_angle if _facing > 0.0 else -(PI - view_angle)


func has_animation(animation: StringName) -> bool:
	return _animation_player != null and _animation_player.has_animation(animation)


func animation_length(animation: StringName) -> float:
	return _animation_player.get_animation(animation).length if has_animation(animation) else 0.0


## Aynı animasyon zaten istenmişse baştan başlatmaz (her karede çağrılabilir).
func play(animation: StringName, blend_time: float = Tuning.MODEL_ANIM_BLEND_TIME) -> void:
	if animation == _requested or not has_animation(animation):
		return
	_requested = animation
	_animation_player.play(animation, blend_time)


func set_speed(speed: float) -> void:
	if _animation_player != null:
		_animation_player.speed_scale = speed


func _build() -> void:
	var frame_px: float = Tuning.MODEL_HEIGHT * Tuning.MODEL_FRAME_RATIO
	var render_px: int = roundi(frame_px * Tuning.MODEL_RENDER_SCALE)

	var viewport := SubViewport.new()
	viewport.name = "ModelViewport"
	viewport.size = Vector2i(render_px, render_px)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	_pivot = Node3D.new()
	_pivot.name = "Pivot"
	viewport.add_child(_pivot)
	var scene: PackedScene = load(MODEL_PATH) as PackedScene
	var model: Node = scene.instantiate()
	_pivot.add_child(model)
	_animation_player = _find_animation_player(model)
	_setup_loops()
	_apply_toon_materials(model)
	var skeleton: Skeleton3D = _find_skeleton(model)
	_attach_jetpack(skeleton)
	_attach_hat(skeleton)
	for slot: StringName in _cosmetics:
		set_cosmetic(slot, _cosmetics[slot])

	_build_camera(viewport)

	var sprite := Sprite2D.new()
	sprite.name = "ModelSprite"
	sprite.texture = viewport.get_texture()
	sprite.scale = Vector2.ONE / Tuning.MODEL_RENDER_SCALE
	# Çerçevenin ortası modelin ortasına (boyun yarısı) denk gelir; ayaklar orijinde kalır.
	sprite.position = Vector2(0.0, -Tuning.MODEL_HEIGHT * 0.5)
	add_child(sprite)


## Model 1 birim boyundadır; çerçeve, kol/kuyruk hareketleri sığsın diye ondan büyüktür.
func _build_camera(viewport: SubViewport) -> void:
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = Tuning.MODEL_FRAME_RATIO
	camera.position = Vector3(-CAMERA_DISTANCE, 0.5, 0.0)
	camera.rotation.y = -PI * 0.5
	camera.near = 0.1
	camera.far = CAMERA_DISTANCE * 2.0
	viewport.add_child(camera)
	camera.make_current()


## Modelin kendi malzemesi yerine toon shader + dış çizgi geçişi kullanılır; doku aynı kalır.
func _apply_toon_materials(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		var outline := ShaderMaterial.new()
		outline.shader = OUTLINE_SHADER
		outline.set_shader_parameter(&"outline_color", Tuning.MODEL_OUTLINE_COLOR)
		outline.set_shader_parameter(&"outline_width", Tuning.MODEL_OUTLINE_WIDTH)
		for surface in mesh_instance.mesh.get_surface_count():
			var source: BaseMaterial3D = mesh_instance.mesh.surface_get_material(surface) as BaseMaterial3D
			var toon := ShaderMaterial.new()
			toon.shader = TOON_SHADER
			if source != null:
				toon.set_shader_parameter(&"albedo_texture", source.albedo_texture)
			CosmeticPaint.setup(toon)
			_toon_materials.append(toon)
			toon.set_shader_parameter(&"rim_color", Tuning.MODEL_RIM_COLOR)
			toon.set_shader_parameter(&"rim_strength", Tuning.MODEL_RIM_STRENGTH)
			toon.set_shader_parameter(&"shadow_tint", Tuning.MODEL_SHADOW_TINT)
			toon.next_pass = outline
			mesh_instance.set_surface_override_material(surface, toon)
	for child in node.get_children():
		_apply_toon_materials(child)


## Roketi göğüs kemiğine bağlar (gizli başlar). Konum model uzayında verilir; kemiğin dinlenme
## dönüşümünün tersiyle kemik uzayına çevrilir → kemik nasıl yönlenmiş olursa olsun roket dik durur.
func _attach_jetpack(skeleton: Skeleton3D) -> void:
	if skeleton == null:
		return
	var bone: int = skeleton.find_bone(JETPACK_BONE)
	if bone == -1:
		return
	var attachment := BoneAttachment3D.new()
	attachment.name = "JetpackAttachment"
	attachment.bone_name = JETPACK_BONE
	skeleton.add_child(attachment)
	_jetpack = JetpackModel.new()
	_jetpack.name = "Jetpack"
	_jetpack.transform = skeleton.get_bone_global_rest(bone).affine_inverse() \
			* Transform3D(Basis.IDENTITY, JETPACK_POSITION)
	attachment.add_child(_jetpack)


## Şapka yeri kafa kemiğine bağlanır (şapkasız başlar). glb'deki şapka dönüşümü model uzayındadır;
## kemiğin dinlenme dönüşümünün tersiyle kemik uzayına çevrilir → kafa nasıl dönerse şapka onunla döner.
func _attach_hat(skeleton: Skeleton3D) -> void:
	if skeleton == null or not HatModel.is_available():
		return
	var bone: int = skeleton.find_bone(HAT_BONE)
	if bone == -1:
		return
	var attachment := BoneAttachment3D.new()
	attachment.name = "HatAttachment"
	attachment.bone_name = HAT_BONE
	skeleton.add_child(attachment)
	_hat = HatModel.new()
	_hat.name = "Hat"
	_hat.transform = skeleton.get_bone_global_rest(bone).affine_inverse()
	attachment.add_child(_hat)


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found: Skeleton3D = _find_skeleton(child)
		if found != null:
			return found
	return null


func _setup_loops() -> void:
	if _animation_player == null:
		return
	for animation_name in LOOPING:
		if _animation_player.has_animation(animation_name):
			_animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found: AnimationPlayer = _find_animation_player(child)
		if found != null:
			return found
	return null
