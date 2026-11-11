extends GutTest
## Smoothing.chaikin testleri.


func test_short_lines_unchanged() -> void:
	var two := PackedVector2Array([Vector2.ZERO, Vector2(10, 0)])
	assert_eq(Smoothing.chaikin(two), two)


func test_endpoints_preserved() -> void:
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(10, 10)])
	var out: PackedVector2Array = Smoothing.chaikin(pts)
	assert_eq(out[0], pts[0])
	assert_eq(out[out.size() - 1], pts[pts.size() - 1])


func test_corner_is_cut() -> void:
	var corner := Vector2(10, 0)
	var pts := PackedVector2Array([Vector2(0, 0), corner, Vector2(10, 10)])
	var out: PackedVector2Array = Smoothing.chaikin(pts)
	assert_false(out.has(corner), "keskin köşe noktası kalmamalı")
	assert_eq(out.size(), 2 * (pts.size() - 1) + 2)
