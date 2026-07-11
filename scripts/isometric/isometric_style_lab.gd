extends Node2D

const EnvironmentScript = preload("res://scripts/isometric/iso_environment.gd")
const PropScript = preload("res://scripts/isometric/iso_prop.gd")
const PlayerScript = preload("res://scripts/isometric/iso_player.gd")
const COMPOSITION_SCALE := 0.82
const STUDIES := ["wukang", "xuhui", "oriental_pearl"]

var environment: Node2D
var player: CharacterBody2D
var y_sort_root: Node2D
var world_root: Node2D
var current_study := "wukang"
var title_label: Label
var subtitle_label: Label


func _ready() -> void:
	var startup_study := "wukang"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--study="):
			startup_study = argument.trim_prefix("--study=")
	_build_world()
	_build_hud()
	_set_study(startup_study)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	if event is InputEventKey:
		match event.keycode:
			KEY_1:
				_set_study("wukang")
			KEY_2:
				_set_study("xuhui")
			KEY_3:
				_set_study("oriental_pearl")


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

	player = PlayerScript.new()
	player.position = Vector2(6, 114)
	y_sort_root.add_child(player)


func _add_prop(kind: int, position: Vector2, tint: Color = Color.WHITE) -> void:
	var prop: Node2D = PropScript.new()
	prop.name = "StudyProp"
	prop.setup(kind, tint)
	prop.position = position
	y_sort_root.add_child(prop)


func _set_study(study_id: String) -> void:
	if study_id not in STUDIES:
		return
	current_study = study_id
	environment.set_study_mode(study_id)
	for child in y_sort_root.get_children():
		if child != player:
			child.queue_free()
	match study_id:
		"xuhui":
			world_root.position = Vector2(320, 172)
			world_root.scale = Vector2.ONE * COMPOSITION_SCALE
			player.position = Vector2(4, 118)
			_add_prop(PropScript.Kind.LAMP, Vector2(-155, 54))
			_add_prop(PropScript.Kind.LAMP, Vector2(166, 71))
			_add_prop(PropScript.Kind.BENCH, Vector2(-63, 106))
			_add_prop(PropScript.Kind.PLANTER, Vector2(119, 132))
		"oriental_pearl":
			world_root.position = Vector2(320, 180)
			world_root.scale = Vector2.ONE * 0.68
			player.position = Vector2(23, 154)
			_add_prop(PropScript.Kind.LAMP, Vector2(190, 98))
			_add_prop(PropScript.Kind.BENCH, Vector2(116, 138))
			_add_prop(PropScript.Kind.PLANTER, Vector2(251, 126))
		_:
			world_root.position = Vector2(320, 172)
			world_root.scale = Vector2.ONE * COMPOSITION_SCALE
			player.position = Vector2(6, 114)
			_add_prop(PropScript.Kind.TREE, Vector2(187, 58), Color("#e0e6d4"))
			_add_prop(PropScript.Kind.TREE, Vector2(-213, 86), Color("#d7e2c9"))
			_add_prop(PropScript.Kind.LAMP, Vector2(116, 63))
			_add_prop(PropScript.Kind.LAMP, Vector2(-121, 83))
			_add_prop(PropScript.Kind.BENCH, Vector2(72, 117))
			_add_prop(PropScript.Kind.CRATES, Vector2(228, 124))
			_add_prop(PropScript.Kind.PLANTER, Vector2(-62, 86))
	_update_study_copy()


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

	title_label = Label.new()
	title_label.position = Vector2(17, 8)
	title_label.text = "SHANGHAI · VISUAL SLICE"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color("#f3e3b1"))
	header.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.position = Vector2(18, 37)
	subtitle_label.text = "Painted isometric study · WASD to explore"
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.add_theme_color_override("font_color", Color("#c8d5cd"))
	header.add_child(subtitle_label)

	var note := Label.new()
	note.position = Vector2(390, 20)
	note.size = Vector2(232, 52)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	note.text = "1 WUKANG · 2 XUHUI · 3 PEARL\nBAKED LIGHT · Y-SORTED DEPTH"
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#fff5d5"))
	canvas.add_child(note)
	_update_study_copy()


func _update_study_copy() -> void:
	if title_label == null or subtitle_label == null:
		return
	match current_study:
		"xuhui":
			title_label.text = "SHANGHAI · XUHUI RIVERSIDE"
			subtitle_label.text = "Industrial waterfront · promenade · river light"
		"oriental_pearl":
			title_label.text = "SHANGHAI · ORIENTAL PEARL"
			subtitle_label.text = "Tripod supports · stacked spheres · Pudong skyline"
		_:
			title_label.text = "SHANGHAI · WUKANG MANSION"
			subtitle_label.text = "Ship-like wedge · arcaded base · plane-tree streets"


func set_study_for_test(study_id: String) -> void:
	_set_study(study_id)


func get_visual_metrics() -> Dictionary:
	return {
		"tile_size": Vector2(EnvironmentScript.TILE_WIDTH, EnvironmentScript.TILE_HEIGHT),
		"prop_count": y_sort_root.get_child_count() - 1,
		"player_present": player != null,
		"layers": 3,
		"study_count": STUDIES.size(),
		"current_study": current_study,
		"study_features": environment.get_study_features(),
	}
