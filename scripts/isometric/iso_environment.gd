class_name IsometricEnvironment
extends Node2D

const TILE_WIDTH := 64.0
const TILE_HEIGHT := 32.0
const LEVEL_HEIGHT := 24.0
const MAP_CENTER := 9.0

const PALETTE := {
	"sky": Color("#9eb3ab"),
	"mortar": Color("#b7a98e"),
	"stone_light": Color("#c8bea2"),
	"stone_mid": Color("#a99f84"),
	"stone_dark": Color("#807762"),
	"road": Color("#5f665f"),
	"road_dark": Color("#4b514d"),
	"brick_light": Color("#9b765d"),
	"brick_mid": Color("#775744"),
	"brick_dark": Color("#533c35"),
	"roof_light": Color("#607b82"),
	"roof_mid": Color("#405b65"),
	"roof_dark": Color("#293f49"),
	"window": Color("#31566a"),
	"window_glow": Color("#d4b875"),
	"shadow": Color(0.13, 0.15, 0.14, 0.34),
}


func _ready() -> void:
	queue_redraw()


func grid_to_screen(x: float, y: float, level: float = 0.0) -> Vector2:
	return Vector2(
		(x - y) * TILE_WIDTH * 0.5,
		(x + y - MAP_CENTER * 2.0) * TILE_HEIGHT * 0.5 - level * LEVEL_HEIGHT
	)


func _draw() -> void:
	draw_rect(Rect2(-520, -310, 1040, 620), PALETTE.sky)
	_draw_ground()
	_draw_building_shadow()
	_draw_wukang_study()
	_draw_courtyard_details()


func _draw_ground() -> void:
	for y in range(18):
		for x in range(18):
			var is_road := x in [1, 2, 3] or y in [14, 15, 16]
			var is_sidewalk := x in [4, 17] or y in [13, 17]
			var color: Color
			if is_road:
				color = PALETTE.road if (x + y) % 3 else PALETTE.road_dark
			elif is_sidewalk:
				color = PALETTE.stone_mid
			else:
				var variation := posmod(x * 11 + y * 7, 4)
				color = [
					PALETTE.stone_light,
					Color("#beb497"),
					PALETTE.mortar,
					Color("#d0c6aa"),
				][variation]
			_draw_ground_tile(x, y, color, is_road)
	_draw_road_markings()


func _draw_ground_tile(x: int, y: int, color: Color, is_road: bool) -> void:
	var top := grid_to_screen(x, y)
	var right := grid_to_screen(x + 1, y)
	var bottom := grid_to_screen(x + 1, y + 1)
	var left := grid_to_screen(x, y + 1)
	var points := PackedVector2Array([top, right, bottom, left])
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([top, right, bottom]), color.darkened(0.16), 1.0)
	if is_road:
		if posmod(x * 5 + y * 3, 5) == 0:
			var center := (top + right + bottom + left) * 0.25
			draw_line(center + Vector2(-8, -1), center + Vector2(4, 4), color.lightened(0.12), 1.0)
		return
	var detail_seed := posmod(x * 13 + y * 17, 9)
	if detail_seed in [0, 3, 7]:
		var center := (top + right + bottom + left) * 0.25
		draw_line(center + Vector2(-8, 1), center + Vector2(-2, -3), color.darkened(0.22), 1.0)
		draw_line(center + Vector2(-2, -3), center + Vector2(5, 0), color.darkened(0.15), 1.0)


func _draw_road_markings() -> void:
	for y in range(2, 17, 3):
		var start := grid_to_screen(2.0, float(y) + 0.2)
		var finish := grid_to_screen(2.0, float(y) + 1.25)
		draw_line(start, finish, Color("#c5b98a"), 3.0)
	for x in range(2, 17, 3):
		var start := grid_to_screen(float(x) + 0.2, 15.0)
		var finish := grid_to_screen(float(x) + 1.25, 15.0)
		draw_line(start, finish, Color("#c5b98a"), 3.0)


func _draw_building_shadow() -> void:
	var shadow := PackedVector2Array([
		grid_to_screen(4.2, 3.2) + Vector2(18, 14),
		grid_to_screen(13.4, 3.2) + Vector2(34, 22),
		grid_to_screen(13.4, 9.3) + Vector2(46, 30),
		grid_to_screen(4.2, 9.3) + Vector2(30, 24),
	])
	draw_colored_polygon(shadow, PALETTE.shadow)


func _draw_wukang_study() -> void:
	_draw_iso_box(4.0, 3.0, 9.0, 5.5, 5.2)
	_draw_front_bands(4.0, 13.0, 8.5, 5.2)
	_draw_front_windows(4.0, 13.0, 8.5, 5.2)
	_draw_side_windows(13.0, 3.0, 8.5, 5.2)
	_draw_front_door(8.5, 8.5)
	_draw_gabled_roof(4.0, 3.0, 9.0, 5.5, 5.2, 1.65)
	_draw_corner_tower()
	_draw_roof_details()


func _draw_iso_box(x: float, y: float, width: float, depth: float, height: float) -> void:
	var top_a := grid_to_screen(x, y, height)
	var top_b := grid_to_screen(x + width, y, height)
	var top_c := grid_to_screen(x + width, y + depth, height)
	var top_d := grid_to_screen(x, y + depth, height)
	var bottom_b := grid_to_screen(x + width, y)
	var bottom_c := grid_to_screen(x + width, y + depth)
	var bottom_d := grid_to_screen(x, y + depth)
	draw_colored_polygon(PackedVector2Array([top_d, top_c, bottom_c, bottom_d]), PALETTE.brick_mid)
	draw_colored_polygon(PackedVector2Array([top_b, top_c, bottom_c, bottom_b]), PALETTE.brick_dark)
	draw_colored_polygon(PackedVector2Array([top_a, top_b, top_c, top_d]), PALETTE.brick_light)
	draw_polyline(PackedVector2Array([top_d, top_c, bottom_c, bottom_d, top_d]), PALETTE.brick_dark.darkened(0.18), 2.0)
	draw_polyline(PackedVector2Array([top_b, top_c, bottom_c, bottom_b, top_b]), PALETTE.brick_dark.darkened(0.25), 2.0)
	_draw_brickwork(x, y, width, depth, height)


func _draw_brickwork(x: float, y: float, width: float, depth: float, height: float) -> void:
	for row in range(1, 10):
		var level := height * float(row) / 10.0
		var front_left := grid_to_screen(x, y + depth, level)
		var front_right := grid_to_screen(x + width, y + depth, level)
		draw_line(front_left, front_right, Color(0.20, 0.14, 0.12, 0.24), 1.0)
		var side_back := grid_to_screen(x + width, y, level)
		var side_front := grid_to_screen(x + width, y + depth, level)
		draw_line(side_back, side_front, Color(0.12, 0.09, 0.09, 0.28), 1.0)
	for column in range(1, 14):
		var px := x + width * float(column) / 14.0
		var z_start := 0.3 if column % 2 else 0.75
		for band in range(5):
			var low := z_start + float(band) * 1.05
			var high := minf(low + 0.42, height - 0.08)
			draw_line(grid_to_screen(px, y + depth, low), grid_to_screen(px, y + depth, high), Color(0.20, 0.14, 0.12, 0.25), 1.0)


func _draw_front_bands(x: float, x_end: float, y: float, height: float) -> void:
	for level in [0.3, 1.72, 3.15, height - 0.18]:
		var left := grid_to_screen(x, y, level)
		var right := grid_to_screen(x_end, y, level)
		draw_line(left, right, Color("#c0a382"), 3.0)
		draw_line(left + Vector2(0, 2), right + Vector2(0, 2), Color("#594238"), 1.0)


func _draw_front_windows(x: float, x_end: float, y: float, height: float) -> void:
	for floor_index in range(3):
		var z_low := 0.58 + float(floor_index) * 1.43
		for window_index in range(7):
			var window_x := x + 0.7 + float(window_index) * (x_end - x - 1.4) / 6.0
			if floor_index == 0 and window_index in [3, 4]:
				continue
			_draw_front_window(window_x, y, z_low, floor_index == 2 and window_index % 3 == 0)


func _draw_front_window(x: float, y: float, z_low: float, glowing: bool) -> void:
	var half_width := 0.34
	var points := PackedVector2Array([
		grid_to_screen(x - half_width, y, z_low + 0.92),
		grid_to_screen(x + half_width, y, z_low + 0.92),
		grid_to_screen(x + half_width, y, z_low),
		grid_to_screen(x - half_width, y, z_low),
	])
	draw_colored_polygon(points, PALETTE.window_glow if glowing else PALETTE.window)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#d0b28f"), 2.0)
	draw_line(points[0].lerp(points[1], 0.5), points[3].lerp(points[2], 0.5), Color("#372f2c"), 1.0)
	draw_line(points[0].lerp(points[3], 0.52), points[1].lerp(points[2], 0.52), Color("#372f2c"), 1.0)


func _draw_side_windows(x: float, y: float, y_end: float, height: float) -> void:
	for floor_index in range(3):
		var z_low := 0.58 + float(floor_index) * 1.43
		for window_index in range(4):
			var window_y := y + 0.85 + float(window_index) * (y_end - y - 1.7) / 3.0
			var points := PackedVector2Array([
				grid_to_screen(x, window_y - 0.3, z_low + 0.9),
				grid_to_screen(x, window_y + 0.3, z_low + 0.9),
				grid_to_screen(x, window_y + 0.3, z_low),
				grid_to_screen(x, window_y - 0.3, z_low),
			])
			draw_colored_polygon(points, PALETTE.window.darkened(0.24))
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#987d68"), 2.0)


func _draw_front_door(x: float, y: float) -> void:
	var points := PackedVector2Array([
		grid_to_screen(x - 0.55, y, 1.52),
		grid_to_screen(x + 0.55, y, 1.52),
		grid_to_screen(x + 0.55, y, 0.08),
		grid_to_screen(x - 0.55, y, 0.08),
	])
	draw_colored_polygon(points, Color("#2e2927"))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#b08b66"), 3.0)
	draw_circle(points[1].lerp(points[2], 0.62), 2.0, Color("#d6b25c"))
	var canopy_left := grid_to_screen(x - 0.85, y, 1.72)
	var canopy_right := grid_to_screen(x + 0.85, y, 1.72)
	draw_line(canopy_left, canopy_right, PALETTE.roof_dark, 6.0)


func _draw_gabled_roof(x: float, y: float, width: float, depth: float, base: float, rise: float) -> void:
	var back_left := grid_to_screen(x, y, base)
	var back_right := grid_to_screen(x + width, y, base)
	var front_left := grid_to_screen(x, y + depth, base)
	var front_right := grid_to_screen(x + width, y + depth, base)
	var ridge_left := grid_to_screen(x, y + depth * 0.5, base + rise)
	var ridge_right := grid_to_screen(x + width, y + depth * 0.5, base + rise)
	draw_colored_polygon(PackedVector2Array([back_left, back_right, ridge_right, ridge_left]), PALETTE.roof_light)
	draw_colored_polygon(PackedVector2Array([front_left, front_right, ridge_right, ridge_left]), PALETTE.roof_mid)
	draw_polyline(PackedVector2Array([ridge_left, ridge_right]), Color("#9ca7a0"), 4.0)
	for stripe in range(1, 10):
		var t := float(stripe) / 10.0
		draw_line(front_left.lerp(front_right, t), ridge_left.lerp(ridge_right, t), PALETTE.roof_dark, 1.0)
	for course in range(1, 5):
		var t := float(course) / 5.0
		draw_line(front_left.lerp(ridge_left, t), front_right.lerp(ridge_right, t), Color(0.18, 0.28, 0.31, 0.58), 1.0)
	for weathering in [Vector2(0.18, 0.34), Vector2(0.43, 0.63), Vector2(0.74, 0.25), Vector2(0.86, 0.69)]:
		var left_edge := front_left.lerp(ridge_left, weathering.y)
		var right_edge := front_right.lerp(ridge_right, weathering.y)
		var point := left_edge.lerp(right_edge, weathering.x)
		draw_rect(Rect2(point + Vector2(-5, -2), Vector2(11, 3)), Color(0.52, 0.62, 0.60, 0.36))


func _draw_corner_tower() -> void:
	var x := 11.2
	var y := 7.25
	_draw_iso_box(x, y, 2.2, 2.0, 6.4)
	_draw_front_window(12.25, 9.25, 1.0, true)
	_draw_front_window(12.25, 9.25, 2.8, false)
	_draw_front_window(12.25, 9.25, 4.6, true)
	var cap_a := grid_to_screen(x, y, 6.4)
	var cap_b := grid_to_screen(x + 2.2, y, 6.4)
	var cap_c := grid_to_screen(x + 2.2, y + 2.0, 6.4)
	var cap_d := grid_to_screen(x, y + 2.0, 6.4)
	var peak := grid_to_screen(x + 1.1, y + 1.0, 8.0)
	draw_colored_polygon(PackedVector2Array([cap_a, cap_b, peak]), PALETTE.roof_light)
	draw_colored_polygon(PackedVector2Array([cap_b, cap_c, peak]), PALETTE.roof_dark)
	draw_colored_polygon(PackedVector2Array([cap_c, cap_d, peak]), PALETTE.roof_mid)


func _draw_roof_details() -> void:
	for chimney in [Vector3(5.8, 4.2, 6.0), Vector3(10.1, 4.8, 6.35)]:
		var base := grid_to_screen(chimney.x, chimney.y, chimney.z)
		draw_rect(Rect2(base + Vector2(-5, -17), Vector2(10, 18)), Color("#60453a"))
		draw_rect(Rect2(base + Vector2(-7, -19), Vector2(14, 4)), Color("#8d6650"))


func _draw_courtyard_details() -> void:
	for patch in [Vector2(7.2, 10.5), Vector2(10.8, 11.8), Vector2(5.6, 12.2)]:
		var center := grid_to_screen(patch.x, patch.y)
		draw_line(center, center + Vector2(-4, -10), Color("#4f7651"), 2.0)
		draw_line(center, center + Vector2(5, -8), Color("#648a58"), 2.0)
		draw_circle(center + Vector2(-4, -10), 2.5, Color("#749a64"))
		draw_circle(center + Vector2(5, -8), 2.5, Color("#5f8a55"))
