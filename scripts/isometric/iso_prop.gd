class_name IsometricProp
extends Node2D

enum Kind { TREE, LAMP, CRATES, BENCH, PLANTER }

var kind: Kind = Kind.TREE
var color_shift: Color = Color.WHITE


func setup(new_kind: Kind, new_color_shift: Color = Color.WHITE) -> void:
	kind = new_kind
	color_shift = new_color_shift


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.TREE:
			_draw_tree()
		Kind.LAMP:
			_draw_lamp()
		Kind.CRATES:
			_draw_crates()
		Kind.BENCH:
			_draw_bench()
		Kind.PLANTER:
			_draw_planter()


func _draw_tree() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-26, 4), Vector2(5, -4), Vector2(34, 7), Vector2(2, 15)]), Color(0.12, 0.15, 0.12, 0.3))
	draw_rect(Rect2(-5, -61, 10, 63), Color("#604936"))
	draw_rect(Rect2(-2, -61, 4, 63), Color("#856247"))
	var dark := Color("#365941") * color_shift
	var mid := Color("#4f7650") * color_shift
	var light := Color("#74935d") * color_shift
	for cluster in [
		{"p": Vector2(-16, -70), "r": 22.0, "c": dark},
		{"p": Vector2(13, -76), "r": 25.0, "c": mid},
		{"p": Vector2(-2, -96), "r": 24.0, "c": mid},
		{"p": Vector2(24, -99), "r": 18.0, "c": dark},
		{"p": Vector2(-24, -99), "r": 18.0, "c": dark},
		{"p": Vector2(1, -116), "r": 17.0, "c": light},
	]:
		draw_circle(cluster.p, cluster.r, cluster.c)
	for sparkle in [Vector2(-10, -114), Vector2(12, -105), Vector2(27, -83), Vector2(-25, -87), Vector2(2, -78)]:
		draw_rect(Rect2(sparkle, Vector2(5, 4)), Color("#91a96f"))


func _draw_lamp() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-10, 3), Vector2(4, -2), Vector2(17, 5), Vector2(2, 9)]), Color(0.10, 0.12, 0.11, 0.32))
	draw_rect(Rect2(-2, -62, 4, 64), Color("#343b3b"))
	draw_rect(Rect2(-9, -70, 18, 12), Color("#293334"))
	draw_rect(Rect2(-6, -67, 12, 7), Color("#e3c779"))
	draw_line(Vector2(-9, -70), Vector2(0, -78), Color("#293334"), 3.0)
	draw_line(Vector2(9, -70), Vector2(0, -78), Color("#293334"), 3.0)


func _draw_crates() -> void:
	_draw_crate(Vector2(-15, -1), 24)
	_draw_crate(Vector2(9, -2), 20)
	_draw_crate(Vector2(-2, -20), 20)


func _draw_crate(origin: Vector2, size: int) -> void:
	draw_rect(Rect2(origin - Vector2(size * 0.5, size), Vector2(size, size)), Color("#765039"))
	draw_rect(Rect2(origin - Vector2(size * 0.5 - 3, size - 3), Vector2(size - 6, size - 6)), Color("#9a6b47"), false, 2.0)
	draw_line(origin - Vector2(size * 0.4, size * 0.85), origin + Vector2(size * 0.4, -size * 0.15), Color("#5b3b2d"), 2.0)


func _draw_bench() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-28, 2), Vector2(9, -6), Vector2(36, 3), Vector2(-2, 11)]), Color(0.12, 0.13, 0.11, 0.25))
	for y in [-23, -14]:
		draw_rect(Rect2(-31, y, 62, 7), Color("#76513a"))
		draw_line(Vector2(-30, y), Vector2(30, y), Color("#a3754d"), 2.0)
	draw_line(Vector2(-23, -9), Vector2(-19, 1), Color("#303838"), 4.0)
	draw_line(Vector2(23, -9), Vector2(19, 1), Color("#303838"), 4.0)


func _draw_planter() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -12), Vector2(0, -20), Vector2(20, -12), Vector2(0, -4)]), Color("#a17b5b"))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -12), Vector2(0, -4), Vector2(0, 9), Vector2(-20, 0)]), Color("#71513e"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -4), Vector2(20, -12), Vector2(20, 0), Vector2(0, 9)]), Color("#5d4639"))
	for leaf in [Vector2(-10, -23), Vector2(-2, -31), Vector2(8, -25), Vector2(13, -35), Vector2(-12, -37)]:
		draw_line(Vector2.ZERO + Vector2(0, -15), leaf, Color("#456b45"), 3.0)
		draw_circle(leaf, 4.5, Color("#6d8e58"))
