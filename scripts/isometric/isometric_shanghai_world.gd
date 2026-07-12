class_name IsometricShanghaiWorld
extends Node2D

const EnvironmentScript = preload("res://scripts/isometric/iso_environment.gd")
const PropScript = preload("res://scripts/isometric/iso_prop.gd")
const PlayerScript = preload("res://scripts/isometric/iso_player.gd")

const DISTRICTS := [
	{"id": "wukang", "label": "WUKANG MANSION", "position": Vector2(0, 0), "spawn": Vector2(0, 156)},
	{"id": "xuhui", "label": "XUHUI RIVERSIDE", "position": Vector2(1040, 0), "spawn": Vector2(1040, 142)},
	{"id": "oriental_pearl", "label": "ORIENTAL PEARL", "position": Vector2(2080, 0), "spawn": Vector2(2250, 246)},
]

var district_root: Node2D
var actor_root: Node2D
var player: CharacterBody2D
var camera: Camera2D
var environments: Array[Node2D] = []
var district_label: Label
var current_district := "wukang"


func _ready() -> void:
	_build_world()
	_build_hud()
	var startup_district := "wukang"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--district="):
			startup_district = argument.trim_prefix("--district=")
	_focus_district(startup_district, startup_district != "wukang")


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo or not event is InputEventKey:
		return
	match event.keycode:
		KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/launcher.tscn")
		KEY_1:
			_focus_district("wukang")
		KEY_2:
			_focus_district("xuhui")
		KEY_3:
			_focus_district("oriental_pearl")


func _process(_delta: float) -> void:
	if player == null:
		return
	var nearest: Dictionary = DISTRICTS[0]
	var nearest_distance := INF
	for district in DISTRICTS:
		var distance := absf(player.position.x - district.position.x)
		if distance < nearest_distance:
			nearest = district
			nearest_distance = distance
	if current_district != nearest.id:
		current_district = nearest.id
		_update_district_label()


func _build_world() -> void:
	district_root = Node2D.new()
	district_root.name = "Districts"
	add_child(district_root)

	for district in DISTRICTS:
		var environment: Node2D = EnvironmentScript.new()
		environment.name = str(district.id).to_pascal_case()
		environment.position = district.position
		environment.set_study_mode(district.id)
		district_root.add_child(environment)
		environments.append(environment)

	actor_root = Node2D.new()
	actor_root.name = "ActorsAndProps"
	actor_root.y_sort_enabled = true
	add_child(actor_root)
	_add_district_props()

	player = PlayerScript.new()
	player.position = DISTRICTS[0].spawn
	player.movement_bounds = Rect2(-492, 42, 3064, 263)
	actor_root.add_child(player)

	camera = Camera2D.new()
	camera.name = "ShanghaiCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = -520
	camera.limit_right = 2600
	camera.limit_top = -310
	camera.limit_bottom = 310
	player.add_child(camera)
	camera.position = Vector2(0, -30)
	camera.make_current()


func _add_district_props() -> void:
	_add_prop(PropScript.Kind.TREE, Vector2(-300, 152), Color("#d7e2c9"))
	_add_prop(PropScript.Kind.LAMP, Vector2(-130, 150))
	_add_prop(PropScript.Kind.BENCH, Vector2(150, 225))
	_add_prop(PropScript.Kind.PLANTER, Vector2(330, 225))
	_add_prop(PropScript.Kind.LAMP, Vector2(870, 124))
	_add_prop(PropScript.Kind.BENCH, Vector2(1130, 132))
	_add_prop(PropScript.Kind.PLANTER, Vector2(1400, 128))
	_add_prop(PropScript.Kind.TREE, Vector2(1870, 238), Color("#d8e0c7"))
	_add_prop(PropScript.Kind.LAMP, Vector2(2250, 252))
	_add_prop(PropScript.Kind.BENCH, Vector2(2440, 262))


func _add_prop(kind: int, prop_position: Vector2, tint: Color = Color.WHITE) -> void:
	var prop: Node2D = PropScript.new()
	prop.setup(kind, tint)
	prop.position = prop_position
	actor_root.add_child(prop)


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "UnifiedShanghaiHUD"
	add_child(canvas)

	var header := ColorRect.new()
	header.position = Vector2(18, 15)
	header.size = Vector2(330, 69)
	header.color = Color("#1f292be8")
	canvas.add_child(header)

	var accent := ColorRect.new()
	accent.size = Vector2(5, 69)
	accent.color = Color("#d5b566")
	header.add_child(accent)

	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "SHANGHAI · UNIFIED 2.5D WORLD"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("#f2e2b7"))
	header.add_child(title)

	district_label = Label.new()
	district_label.position = Vector2(18, 34)
	district_label.add_theme_font_size_override("font_size", 13)
	district_label.add_theme_color_override("font_color", Color("#bcd0c7"))
	header.add_child(district_label)

	var help := Label.new()
	help.position = Vector2(372, 20)
	help.size = Vector2(250, 54)
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	help.text = "WASD / ARROWS TO WALK\n1 WUKANG · 2 XUHUI · 3 PEARL · ESC MENU"
	help.add_theme_font_size_override("font_size", 10)
	help.add_theme_color_override("font_color", Color("#fff1c9"))
	canvas.add_child(help)
	_update_district_label()


func _focus_district(district_id: String, teleport: bool = true) -> void:
	for district in DISTRICTS:
		if district.id == district_id:
			current_district = district_id
			if teleport and player != null:
				player.position = district.spawn
				player.velocity = Vector2.ZERO
				if camera != null:
					camera.reset_smoothing()
			_update_district_label()
			return


func _update_district_label() -> void:
	if district_label == null:
		return
	for district in DISTRICTS:
		if district.id == current_district:
			district_label.text = "%s · ONE CONNECTED MAP" % district.label
			return


func focus_district_for_test(district_id: String) -> void:
	_focus_district(district_id)


func probe_wukang_collision_for_test() -> bool:
	if player == null:
		return false
	var original_position := player.position
	player.position = Vector2(100, 132)
	var collision := player.move_and_collide(Vector2(0, -110), true)
	player.position = original_position
	return collision != null


func get_world_metrics() -> Dictionary:
	var collision_count := 0
	var modes := PackedStringArray()
	for environment in environments:
		collision_count += environment.get_collision_shape_count()
		modes.append(environment.study_mode)
	return {
		"district_count": environments.size(),
		"district_modes": modes,
		"collision_shape_count": collision_count,
		"camera_present": camera != null,
		"player_present": player != null,
		"world_width": 3120,
		"current_district": current_district,
	}
