extends GutTest
## Kalp (can) kuralları: çıkma koşulları, bölüm geçişi kalbi, üst sınır, harcama ve oyun turu bazlı olması;
## kurtarma uçuşunun kısa süresi.

const GameStateScript: GDScript = preload("res://scripts/autoload/game_state.gd")
const TEMP_SAVE: String = "user://test_hearts_save.cfg"
const DT: float = 1.0 / 60.0

var _saved_path: String


func before_each() -> void:
	_saved_path = SaveData.path
	SaveData.path = TEMP_SAVE


func after_each() -> void:
	if FileAccess.file_exists(TEMP_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE))
	SaveData.path = _saved_path


func test_heart_spawn_conditions() -> void:
	var far_back: int = -Tuning.HEART_MIN_FLOOR_GAP * 10
	assert_false(PickupRules.can_spawn_heart(Tuning.HEART_MIN_FLOOR - 1, far_back))
	assert_eq(PickupRules.can_spawn_heart(Tuning.HEART_MIN_FLOOR, far_back), Tuning.HEART_ENABLED)
	var last: int = Tuning.HEART_MIN_FLOOR + 20
	assert_false(PickupRules.can_spawn_heart(last + Tuning.HEART_MIN_FLOOR_GAP - 1, last), "aralık dolmadan çıkmaz")
	var floor_number: int = last + Tuning.HEART_MIN_FLOOR_GAP
	assert_eq(PickupRules.should_spawn_heart(floor_number, last, Tuning.HEART_SPAWN_CHANCE * 0.5), Tuning.HEART_ENABLED)
	assert_false(PickupRules.should_spawn_heart(floor_number, last, Tuning.HEART_SPAWN_CHANCE + 0.01))


func test_heart_is_rarer_than_diamond() -> void:
	assert_lt(Tuning.HEART_SPAWN_CHANCE, Tuning.DIAMOND_SPAWN_CHANCE)


func test_sections_crossed() -> void:
	var interval: int = Tuning.SECTION_FLOOR_INTERVAL
	assert_eq(PickupRules.sections_crossed(interval - 1, interval), 1)
	assert_eq(PickupRules.sections_crossed(interval, interval + 5), 0, "aynı bölümde")
	assert_eq(PickupRules.sections_crossed(interval - 3, interval * 3), 3, "uçarken birden fazla bölüm")
	assert_eq(PickupRules.sections_crossed(interval * 2, 0), 0, "sıfırlamada kalp yok")


func test_add_hearts_is_capped() -> void:
	assert_eq(PickupRules.add_hearts(Tuning.HEART_MAX - 1, 3), Tuning.HEART_MAX)
	assert_eq(PickupRules.add_hearts(0, 1), 1)


func test_section_gives_heart_and_heart_is_spent() -> void:
	var state: Node = _new_state()
	assert_eq(state.hearts, Tuning.HEART_START)
	state.register_landing(Tuning.SECTION_FLOOR_INTERVAL)
	var expected: int = mini(Tuning.HEART_START + Tuning.HEART_SECTION_BONUS, Tuning.HEART_MAX)
	assert_eq(state.hearts, expected, "bölüm geçişinde kalp")
	state.register_landing(Tuning.SECTION_FLOOR_INTERVAL)
	assert_eq(state.hearts, expected, "aynı bölüm platformuna tekrar inmek kalp vermez")
	for i: int in expected:
		assert_true(state.use_heart(), "kalp varken ölüm harcar")
	assert_false(state.use_heart(), "kalp yoksa oyun biter")
	assert_false(state.is_game_over, "use_heart oyunu kendisi bitirmez")


func test_flight_floors_also_cross_sections() -> void:
	var state: Node = _new_state()
	state.begin_flight()
	state.register_flight_floor(Tuning.SECTION_FLOOR_INTERVAL + 3)
	assert_eq(state.hearts, PickupRules.add_hearts(Tuning.HEART_START, Tuning.HEART_SECTION_BONUS))


func test_hearts_are_per_run() -> void:
	var state: Node = _new_state()
	state.add_hearts(2)
	assert_eq(state.hearts, PickupRules.add_hearts(Tuning.HEART_START, 2))
	state.end_game()
	state.add_hearts(1)
	assert_false(state.use_heart(), "oyun bittikten sonra kalp harcanmaz")
	state.reset()
	assert_eq(state.hearts, Tuning.HEART_START, "yeni oyunda kalpler birikmez")


func test_rescue_flight_is_short() -> void:
	var flight := JetpackFlight.new(Tuning.HEART_RESCUE_FLIGHT_TIME)
	var boost_steps: int = 0
	var velocity := Vector2.ZERO
	while flight.phase == JetpackFlight.Phase.BOOST and boost_steps < 1000:
		velocity = flight.step(Vector2.ZERO, velocity, 0.0, DT, Callable())
		boost_steps += 1
	assert_almost_eq(boost_steps * DT, Tuning.HEART_RESCUE_FLIGHT_TIME, 0.05)
	assert_almost_eq(JetpackRules.fuel_ratio(Tuning.HEART_RESCUE_FLIGHT_TIME * 0.5,
			Tuning.HEART_RESCUE_FLIGHT_TIME), 0.5, 0.001)


## Çizimdeki çokgenler üçgenlenebilmeli (yoksa Godot "Invalid polygon data" verir ve şekil çizilmez).
func test_heart_polygons_are_valid() -> void:
	assert_false(Geometry2D.triangulate_polygon(HeartArt.outline_points(Vector2.ZERO, 1.0)).is_empty(), "tam kalp")
	for side: float in [-1.0, 1.0]:
		assert_false(Geometry2D.triangulate_polygon(HeartArt.half_points(side)).is_empty(), "yarım kalp %d" % side)


func _new_state() -> Node:
	var state: Node = GameStateScript.new()
	state.set_physics_process(false)
	add_child_autofree(state)
	return state
