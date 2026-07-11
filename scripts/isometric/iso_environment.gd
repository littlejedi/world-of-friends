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

var study_mode := "wukang"


func _ready() -> void:
	queue_redraw()


func set_study_mode(new_mode: String) -> void:
	study_mode = new_mode
	queue_redraw()


func get_study_features() -> PackedStringArray:
	match study_mode:
		"xuhui":
			return PackedStringArray(["river", "promenade", "running_track", "industrial_cranes", "skyline"])
		"oriental_pearl":
			return PackedStringArray(["tripod_supports", "lower_sphere", "upper_sphere", "stacked_decks", "spire"])
		_:
			return PackedStringArray(["ship_wedge", "arcaded_base", "red_brick", "balconies", "plane_trees"])


func grid_to_screen(x: float, y: float, level: float = 0.0) -> Vector2:
	return Vector2(
		(x - y) * TILE_WIDTH * 0.5,
		(x + y - MAP_CENTER * 2.0) * TILE_HEIGHT * 0.5 - level * LEVEL_HEIGHT
	)


func _draw() -> void:
	match study_mode:
		"xuhui":
			_draw_xuhui_riverside()
		"oriental_pearl":
			_draw_oriental_pearl_study()
		_:
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
	_draw_arcaded_base(4.0, 10.8, 8.5)
	_draw_front_windows(4.0, 13.0, 8.5, 5.2)
	_draw_side_windows(13.0, 3.0, 8.5, 5.2)
	_draw_front_door(8.5, 8.5)
	_draw_gabled_roof(4.0, 3.0, 9.0, 5.5, 5.2, 1.65)
	_draw_corner_tower()
	_draw_roof_details()


func _draw_arcaded_base(x: float, x_end: float, y: float) -> void:
	var base_face := PackedVector2Array([
		grid_to_screen(x, y, 1.48),
		grid_to_screen(x_end, y, 1.48),
		grid_to_screen(x_end, y, 0.05),
		grid_to_screen(x, y, 0.05),
	])
	draw_colored_polygon(base_face, Color("#9a8e79"))
	for arcade_index in range(5):
		var center_x := x + 0.72 + float(arcade_index) * (x_end - x - 1.44) / 4.0
		var top_center := grid_to_screen(center_x, y, 1.16)
		var bottom_center := grid_to_screen(center_x, y, 0.08)
		var opening := PackedVector2Array([
			top_center + Vector2(-10, -3),
			top_center + Vector2(10, 2),
			bottom_center + Vector2(10, 2),
			bottom_center + Vector2(-10, -3),
		])
		draw_colored_polygon(opening, Color("#343336") if arcade_index != 2 else Color("#3d5460"))
		draw_arc(top_center, 10.5, PI, TAU, 12, Color("#c0ae90"), 3.0)
		draw_line(opening[0], opening[3], Color("#c0ae90"), 2.0)
		draw_line(opening[1], opening[2], Color("#8b7b69"), 2.0)
	for balcony_x in [5.15, 7.15, 9.3]:
		var center := grid_to_screen(balcony_x, y, 3.08)
		draw_line(center + Vector2(-14, 2), center + Vector2(14, 9), Color("#403c3a"), 3.0)
		for rail in range(-10, 11, 5):
			draw_line(center + Vector2(rail, -4 + float(rail) * 0.25), center + Vector2(rail, 4 + float(rail) * 0.25), Color("#494442"), 1.0)


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
			if floor_index == 0 and window_index <= 5:
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
	var height := 6.45
	var base_left := grid_to_screen(10.7, 8.5)
	var base_tip := grid_to_screen(13.9, 10.0)
	var base_right := grid_to_screen(13.1, 6.85)
	var top_left := grid_to_screen(10.7, 8.5, height)
	var top_tip := grid_to_screen(13.9, 10.0, height)
	var top_right := grid_to_screen(13.1, 6.85, height)
	draw_colored_polygon(PackedVector2Array([top_left, top_tip, base_tip, base_left]), PALETTE.brick_mid.lightened(0.04))
	draw_colored_polygon(PackedVector2Array([top_right, top_tip, base_tip, base_right]), PALETTE.brick_dark)
	for level in [0.32, 1.75, 3.18, 4.62, 6.18]:
		draw_line(grid_to_screen(10.7, 8.5, level), grid_to_screen(13.9, 10.0, level), Color("#b49372"), 3.0)
		draw_line(grid_to_screen(13.1, 6.85, level), grid_to_screen(13.9, 10.0, level), Color("#806552"), 2.0)
	for floor_index in range(4):
		var z_low := 0.62 + float(floor_index) * 1.43
		_draw_wedge_window(top_left.lerp(top_tip, 0.46), base_left.lerp(base_tip, 0.46), z_low / height, floor_index % 3 == 0)
		_draw_wedge_window(top_right.lerp(top_tip, 0.48), base_right.lerp(base_tip, 0.48), z_low / height, floor_index == 2)
	var peak := grid_to_screen(12.5, 8.55, 8.25)
	draw_colored_polygon(PackedVector2Array([top_left, top_tip, peak]), PALETTE.roof_mid)
	draw_colored_polygon(PackedVector2Array([top_right, top_tip, peak]), PALETTE.roof_dark)
	draw_colored_polygon(PackedVector2Array([top_left, top_right, peak]), PALETTE.roof_light)
	draw_line(top_tip, peak, Color("#9aa59e"), 3.0)


func _draw_wedge_window(top_anchor: Vector2, bottom_anchor: Vector2, vertical_t: float, glowing: bool) -> void:
	var center := bottom_anchor.lerp(top_anchor, vertical_t + 0.075)
	var points := PackedVector2Array([
		center + Vector2(-7, -11),
		center + Vector2(7, -8),
		center + Vector2(7, 8),
		center + Vector2(-7, 5),
	])
	draw_colored_polygon(points, PALETTE.window_glow if glowing else PALETTE.window)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#b69373"), 2.0)


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


func _draw_xuhui_riverside() -> void:
	draw_rect(Rect2(-520, -310, 1040, 620), Color("#91aaa9"))
	_draw_riverside_skyline()
	var water := PackedVector2Array([Vector2(-520, -112), Vector2(520, -112), Vector2(520, 26), Vector2(-520, 26)])
	draw_colored_polygon(water, Color("#537f88"))
	for row in range(9):
		var y := -98.0 + float(row) * 14.0
		for segment in range(8):
			var x := -485.0 + float(segment) * 145.0 + float((row * 37 + segment * 19) % 35)
			var length := 28.0 + float((row * 13 + segment * 7) % 34)
			draw_line(Vector2(x, y), Vector2(x + length, y - 3), Color(0.67, 0.82, 0.79, 0.38), 2.0)
	_draw_riverboat(Vector2(205, -51))

	var promenade := PackedVector2Array([Vector2(-520, 5), Vector2(520, 5), Vector2(520, 310), Vector2(-520, 310)])
	draw_colored_polygon(promenade, Color("#b9b39d"))
	for row in range(10):
		var y := 25.0 + float(row) * 29.0
		draw_line(Vector2(-520, y), Vector2(520, y), Color(0.38, 0.36, 0.31, 0.22), 1.0)
	for column in range(22):
		var x := -500.0 + float(column) * 48.0
		var offset := 14.0 if column % 2 else 0.0
		draw_line(Vector2(x, 5 + offset), Vector2(x, 310), Color(0.42, 0.40, 0.35, 0.16), 1.0)

	var running_track := PackedVector2Array([Vector2(-520, 184), Vector2(520, 184), Vector2(520, 242), Vector2(-520, 242)])
	draw_colored_polygon(running_track, Color("#a75246"))
	draw_line(Vector2(-520, 193), Vector2(520, 193), Color("#d7c7a5"), 2.0)
	draw_line(Vector2(-520, 232), Vector2(520, 232), Color("#d7c7a5"), 2.0)

	_draw_riverside_railing()
	_draw_industrial_crane(Vector2(-250, 1))
	_draw_industrial_crane(Vector2(330, 1), 0.78)
	_draw_riverside_greenery()


func _draw_riverside_skyline() -> void:
	var skyline_base := -112.0
	draw_rect(Rect2(-520, -310, 1040, 198), Color("#aebbb0"))
	var buildings := [
		{"x": -465.0, "w": 75.0, "h": 72.0, "c": Color("#66747a")},
		{"x": -375.0, "w": 52.0, "h": 105.0, "c": Color("#596b72")},
		{"x": -302.0, "w": 88.0, "h": 61.0, "c": Color("#74817f")},
		{"x": -196.0, "w": 62.0, "h": 125.0, "c": Color("#53666f")},
		{"x": -115.0, "w": 92.0, "h": 86.0, "c": Color("#687879")},
		{"x": 5.0, "w": 56.0, "h": 111.0, "c": Color("#52666c")},
		{"x": 78.0, "w": 98.0, "h": 74.0, "c": Color("#73817f")},
		{"x": 198.0, "w": 70.0, "h": 132.0, "c": Color("#596d73")},
		{"x": 287.0, "w": 104.0, "h": 82.0, "c": Color("#687b7b")},
		{"x": 414.0, "w": 76.0, "h": 116.0, "c": Color("#53676e")},
	]
	for building in buildings:
		var rect := Rect2(building.x, skyline_base - building.h, building.w, building.h)
		draw_rect(rect, building.c)
		draw_rect(Rect2(rect.position + Vector2(7, 8), rect.size - Vector2(14, 14)), building.c.lightened(0.08), false, 2.0)
		for floor_y in range(int(rect.position.y) + 13, int(skyline_base) - 6, 14):
			draw_line(Vector2(rect.position.x + 8, floor_y), Vector2(rect.end.x - 8, floor_y), Color(0.73, 0.80, 0.76, 0.26), 1.0)


func _draw_riverboat(center: Vector2) -> void:
	var hull := PackedVector2Array([
		center + Vector2(-49, 0), center + Vector2(48, 0), center + Vector2(34, 15), center + Vector2(-36, 15)
	])
	draw_colored_polygon(hull, Color("#493e36"))
	draw_rect(Rect2(center + Vector2(-28, -18), Vector2(57, 19)), Color("#d5c7a6"))
	draw_rect(Rect2(center + Vector2(-17, -28), Vector2(34, 11)), Color("#aeb7ad"))
	for window_x in [-20, -8, 4, 16]:
		draw_rect(Rect2(center + Vector2(window_x, -13), Vector2(7, 7)), Color("#355967"))
	draw_line(center + Vector2(-58, 20), center + Vector2(57, 20), Color(0.76, 0.87, 0.83, 0.4), 2.0)


func _draw_riverside_railing() -> void:
	draw_line(Vector2(-520, 9), Vector2(520, 9), Color("#353e3f"), 5.0)
	draw_line(Vector2(-520, 24), Vector2(520, 24), Color("#5b6360"), 2.0)
	for x in range(-500, 521, 38):
		draw_line(Vector2(x, 7), Vector2(x, 40), Color("#333b3c"), 3.0)


func _draw_industrial_crane(base: Vector2, scale_factor: float = 1.0) -> void:
	var orange := Color("#c66d3e")
	draw_line(base, base + Vector2(0, -128) * scale_factor, orange.darkened(0.18), 11.0 * scale_factor)
	draw_line(base + Vector2(0, -122) * scale_factor, base + Vector2(93, -154) * scale_factor, orange, 10.0 * scale_factor)
	draw_line(base + Vector2(10, -115) * scale_factor, base + Vector2(68, -145) * scale_factor, Color("#e09254"), 3.0 * scale_factor)
	draw_line(base + Vector2(77, -148) * scale_factor, base + Vector2(77, -67) * scale_factor, Color("#4c4841"), 2.0)
	draw_rect(Rect2(base + Vector2(68, -72) * scale_factor, Vector2(18, 12) * scale_factor), Color("#514943"))
	draw_rect(Rect2(base + Vector2(-22, -6) * scale_factor, Vector2(44, 14) * scale_factor), orange.darkened(0.24))


func _draw_riverside_greenery() -> void:
	for x in range(-470, 500, 92):
		draw_circle(Vector2(x, 278), 22.0, Color("#466c4c"))
		draw_circle(Vector2(x + 17, 270), 17.0, Color("#62855a"))
		draw_rect(Rect2(x + 4, 285, 6, 26), Color("#66503d"))
	for x in range(-430, 460, 125):
		draw_rect(Rect2(x, 91, 72, 12), Color("#72523d"))
		draw_line(Vector2(x + 8, 103), Vector2(x + 8, 118), Color("#373b39"), 3.0)
		draw_line(Vector2(x + 64, 103), Vector2(x + 64, 118), Color("#373b39"), 3.0)


func _draw_oriental_pearl_study() -> void:
	draw_rect(Rect2(-520, -310, 1040, 620), Color("#8fa7ac"))
	_draw_lujiazui_background()
	var river := PackedVector2Array([Vector2(-520, -40), Vector2(-112, -95), Vector2(-34, 310), Vector2(-520, 310)])
	draw_colored_polygon(river, Color("#4e7b86"))
	for row in range(10):
		var y := -5.0 + float(row) * 31.0
		for segment in range(4):
			var x := -485.0 + float(segment) * 105.0 + float((row * 17 + segment * 9) % 27)
			draw_line(Vector2(x, y), Vector2(x + 46, y - 7), Color(0.65, 0.82, 0.80, 0.35), 2.0)
	var plaza := PackedVector2Array([Vector2(-108, -95), Vector2(520, -35), Vector2(520, 310), Vector2(-34, 310)])
	draw_colored_polygon(plaza, Color("#aaa995"))
	for y in range(-55, 310, 28):
		draw_line(Vector2(-96 + float(y + 55) * 0.18, y), Vector2(520, y + 48), Color(0.36, 0.36, 0.32, 0.22), 1.0)
	for x in range(-40, 520, 42):
		draw_line(Vector2(x, -78), Vector2(x + 58, 310), Color(0.38, 0.38, 0.34, 0.18), 1.0)
	_draw_oriental_pearl_tower(Vector2(96, 190))
	_draw_plaza_trees()


func _draw_lujiazui_background() -> void:
	for building in [
		{"r": Rect2(-415, -233, 93, 193), "c": Color("#4e6570")},
		{"r": Rect2(-309, -183, 81, 133), "c": Color("#62757a")},
		{"r": Rect2(-205, -261, 74, 190), "c": Color("#455b66")},
		{"r": Rect2(261, -223, 88, 198), "c": Color("#536b75")},
		{"r": Rect2(365, -176, 102, 156), "c": Color("#63787c")},
	]:
		draw_rect(building.r, building.c)
		for floor_y in range(int(building.r.position.y) + 13, int(building.r.end.y) - 7, 15):
			draw_line(Vector2(building.r.position.x + 8, floor_y), Vector2(building.r.end.x - 8, floor_y), Color(0.72, 0.82, 0.82, 0.25), 1.0)


func _draw_oriental_pearl_tower(base: Vector2) -> void:
	var shadow := PackedVector2Array([base + Vector2(-55, 8), base + Vector2(20, -5), base + Vector2(126, 35), base + Vector2(43, 52)])
	draw_colored_polygon(shadow, Color(0.13, 0.15, 0.15, 0.3))
	var steel := Color("#d4c9b1")
	var steel_shadow := Color("#857f75")
	var red := Color("#a84d5a")
	draw_line(base + Vector2(-48, 0), base + Vector2(-12, -126), steel_shadow, 13.0)
	draw_line(base + Vector2(48, 0), base + Vector2(12, -126), steel, 13.0)
	draw_line(base, base + Vector2(0, -340), Color("#c7c0ad"), 12.0)
	draw_line(base + Vector2(-22, -108), base + Vector2(0, -188), Color("#746f69"), 8.0)
	draw_line(base + Vector2(22, -108), base + Vector2(0, -188), steel, 8.0)
	_draw_pixel_orb(base + Vector2(0, -128), 57.0, red)
	draw_rect(Rect2(base + Vector2(-39, -195), Vector2(78, 13)), Color("#6d6460"))
	_draw_pixel_orb(base + Vector2(0, -236), 33.0, Color("#b75a66"))
	draw_rect(Rect2(base + Vector2(-25, -276), Vector2(50, 10)), Color("#6e6661"))
	_draw_pixel_orb(base + Vector2(0, -297), 18.0, Color("#a84757"))
	draw_line(base + Vector2(0, -314), base + Vector2(0, -389), Color("#bdb7a9"), 7.0)
	draw_line(base + Vector2(0, -389), base + Vector2(0, -421), Color("#a95059"), 3.0)
	for ring_y in [-165, -188, -264, -276, -326]:
		draw_line(base + Vector2(-19, ring_y), base + Vector2(19, ring_y), Color("#d3c7ad"), 3.0)


func _draw_pixel_orb(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(-radius * 0.55, -radius),
		center + Vector2(radius * 0.55, -radius),
		center + Vector2(radius, -radius * 0.45),
		center + Vector2(radius, radius * 0.45),
		center + Vector2(radius * 0.55, radius),
		center + Vector2(-radius * 0.55, radius),
		center + Vector2(-radius, radius * 0.45),
		center + Vector2(-radius, -radius * 0.45),
	])
	draw_colored_polygon(points, color)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-radius * 0.55, -radius), center + Vector2(radius * 0.08, -radius),
		center + Vector2(-radius * 0.08, radius), center + Vector2(-radius * 0.55, radius),
		center + Vector2(-radius, radius * 0.45), center + Vector2(-radius, -radius * 0.45),
	]), color.lightened(0.22))
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color.darkened(0.3), 3.0)
	draw_line(center + Vector2(-radius * 0.82, -radius * 0.48), center + Vector2(radius * 0.82, -radius * 0.48), color.lightened(0.18), 2.0)


func _draw_plaza_trees() -> void:
	for center in [Vector2(265, 165), Vector2(355, 224), Vector2(447, 135)]:
		draw_rect(Rect2(center + Vector2(-4, -2), Vector2(8, 48)), Color("#66513f"))
		draw_circle(center + Vector2(-11, -18), 23.0, Color("#436a4c"))
		draw_circle(center + Vector2(13, -22), 25.0, Color("#587d54"))
		draw_circle(center + Vector2(1, -43), 21.0, Color("#6b8c5d"))
