extends GutTest
## WallClearance testleri: görüntü duvarın içine taşmaz, duvardan uzakta kaymaz.

const HALF_TOWER: float = Tuning.TOWER_WIDTH * 0.5
const HALF_VISUAL: float = Tuning.MODEL_WALL_HALF_WIDTH
const HALF_HITBOX: float = Tuning.PLAYER_WIDTH * 0.5


func test_no_offset_away_from_walls() -> void:
	assert_eq(WallClearance.offset_x(0.0, HALF_VISUAL, HALF_TOWER), 0.0)
	assert_eq(WallClearance.offset_x(HALF_TOWER - HALF_VISUAL - 1.0, HALF_VISUAL, HALF_TOWER), 0.0)


func test_pushes_inward_at_right_wall() -> void:
	# Hitbox sağ duvara dayalı: görüntünün sağ kenarı tam duvarın iç yüzünde olmalı.
	var x: float = HALF_TOWER - HALF_HITBOX
	var offset: float = WallClearance.offset_x(x, HALF_VISUAL, HALF_TOWER)
	assert_almost_eq(x + offset + HALF_VISUAL, HALF_TOWER, 0.001)
	assert_lt(offset, 0.0)


func test_pushes_inward_at_left_wall() -> void:
	var x: float = -(HALF_TOWER - HALF_HITBOX)
	var offset: float = WallClearance.offset_x(x, HALF_VISUAL, HALF_TOWER)
	assert_almost_eq(x + offset - HALF_VISUAL, -HALF_TOWER, 0.001)
	assert_gt(offset, 0.0)


func test_offset_is_continuous_near_wall() -> void:
	var previous: float = 0.0
	var x: float = HALF_TOWER - HALF_VISUAL - 2.0
	while x <= HALF_TOWER - HALF_HITBOX:
		var offset: float = WallClearance.offset_x(x, HALF_VISUAL, HALF_TOWER)
		assert_almost_eq(offset, previous, 1.01)
		previous = offset
		x += 1.0


func test_visual_wider_than_tower_does_not_explode() -> void:
	assert_eq(WallClearance.offset_x(10.0, HALF_TOWER * 2.0, HALF_TOWER), -10.0)
