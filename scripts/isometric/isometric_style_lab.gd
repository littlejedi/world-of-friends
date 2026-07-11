extends Node2D

const EnvironmentScript = preload("res://scripts/isometric/iso_environment.gd")
const PropScript = preload("res://scripts/isometric/iso_prop.gd")
const PlayerScript = preload("res://scripts/isometric/iso_player.gd")
const COMPOSITION_SCALE := 0.82

var environment: Node2D
var player: CharacterBody2D
var y_sort_root: Node2D
var world_root: Node2D


func _ready() -> void:
	_build_world()
	_build_hud()


func _build_world() -> void:
	world_root = Node2D.new()
	world_root.name = "IsometricWorld"
	world_root.position = Vector2(320, 172)
	world_root.scale = Vector2.ONE * COMPOSITION_SCALE
	add_child(world_root)

	environment = EnvironmentScript.new()
	environment.name = "PaintedEnvironment"
	world_root.add_child(environment)

	y_sort_root = Node2D.new()
	y_sort_root.name = "YSortedActorsAndProps"
	y_sort_root.y_sort_enabled = true
	world_root.add_child(y_sort_root)

	_add_prop(PropScript.Kind.TREE, Vector2(187, 58), Color("#e0e6d4"))
	_add_prop(PropScript.Kind.TREE, Vector2(-213, 86), Color("#d7e2c9"))
	_add_prop(PropScript.Kind.LAMP, Vector2(116, 63))
	_add_prop(PropScript.Kind.LAMP, Vector2(-121, 83))
	_add_prop(PropScript.Kind.BENCH, Vector2(72, 117))
	_add_prop(PropScript.Kind.CRATES, Vector2(228, 124))
	_add_prop(PropScript.Kind.PLANTER, Vector2(-62, 86))

	player = PlayerScript.new()
	player.position = Vector2(6, 114)
	y_sort_root.add_child(player)


func _add_prop(kind: int, position: Vector2, tint: Color = Color.WHITE) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(kind, tint)
	prop.position = position
	y_sort_root.add_child(prop)


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "StyleLabHUD"
	add_child(canvas)

	var header := ColorRect.new()
	header.position = Vector2(18, 15)
	header.size = Vector2(334, 72)
	header.color = Color("#1f2730e8")
	canvas.add_child(header)

	var accent := ColorRect.new()
	accent.position = Vector2(0, 0)
	accent.size = Vector2(5, 72)
	accent.color = Color("#d6b566")
	header.add_child(accent)

	var title := Label.new()
	title.position = Vector2(17, 8)
	title.text = "SHANGHAI · VISUAL SLICE"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#f3e3b1"))
	header.add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(18, 37)
	subtitle.text = "Painted isometric study · WASD to explore"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#c8d5cd"))
	header.add_child(subtitle)

	var note := Label.new()
	note.position = Vector2(390, 20)
	note.size = Vector2(232, 52)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	note.text = "64×32 TILE GRID\nBAKED LIGHT · Y-SORTED DEPTH"
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#fff5d5"))
	canvas.add_child(note)


func get_visual_metrics() -> Dictionary:
	return {
		"tile_size": Vector2(EnvironmentScript.TILE_WIDTH, EnvironmentScript.TILE_HEIGHT),
		"prop_count": y_sort_root.get_child_count() - 1,
		"player_present": player != null,
		"layers": 3,
	}
