class_name WorldOfFriendsLauncher
extends Control

const ISOMETRIC_SCENE := "res://scenes/isometric_shanghai_world.tscn"
const CLASSIC_SCENE := "res://scenes/main.tscn"

var isometric_button: Button
var classic_button: Button


func _ready() -> void:
	set_process_unhandled_key_input(true)
	_build_interface()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#182326"))
	for row in range(12):
		for column in range(22):
			var center := Vector2(float(column) * 34.0 - 30.0, 235.0 + float(row) * 17.0)
			center.x += float(row) * 17.0
			var tile := PackedVector2Array([
				center + Vector2(0, -9),
				center + Vector2(17, 0),
				center + Vector2(0, 9),
				center + Vector2(-17, 0),
			])
			var tone := Color("#354342") if (row + column) % 2 == 0 else Color("#303d3c")
			draw_colored_polygon(tile, tone)
			draw_polyline(PackedVector2Array([tile[0], tile[1], tile[2]]), Color("#455351"), 1.0)
	draw_circle(Vector2(535, 78), 84.0, Color("#233d43"))
	draw_circle(Vector2(535, 78), 58.0, Color("#294c55"))
	draw_line(Vector2(488, 119), Vector2(582, 37), Color("#d1b46d"), 3.0)
	draw_line(Vector2(500, 132), Vector2(594, 50), Color("#8ca2a0"), 2.0)


func _build_interface() -> void:
	var title := Label.new()
	title.position = Vector2(38, 29)
	title.text = "WORLD OF FRIENDS"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#f3dfaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(41, 69)
	subtitle.text = "Choose the world you want to explore"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("#b8cbc5"))
	add_child(subtitle)

	var accent := ColorRect.new()
	accent.position = Vector2(41, 99)
	accent.size = Vector2(82, 4)
	accent.color = Color("#d1b46d")
	add_child(accent)

	var isometric_panel := _make_mode_panel(
		Vector2(38, 126),
		"NEW VISUAL DIRECTION",
		"2.5D SHANGHAI",
		"One connected pixel-art Shanghai map.\nWalk between Wukang Mansion, Xuhui Riverside,\nand the Oriental Pearl Tower.",
		Color("#6e493b")
	)
	add_child(isometric_panel)
	isometric_button = _make_button("EXPLORE 2.5D SHANGHAI", Color("#d0a65c"))
	isometric_button.position = Vector2(18, 137)
	isometric_button.pressed.connect(_open_isometric)
	isometric_panel.add_child(isometric_button)

	var classic_panel := _make_mode_panel(
		Vector2(334, 126),
		"COMPLETE PROTOTYPE",
		"SHANGHAI ↔ SEATTLE",
		"The existing 3D gameplay loop with shuttle travel,\nKent and Joey, conversations, city guides,\nand card trading.",
		Color("#294c55")
	)
	add_child(classic_panel)
	classic_button = _make_button("PLAY 3D PROTOTYPE", Color("#547f80"))
	classic_button.position = Vector2(18, 137)
	classic_button.pressed.connect(_open_classic)
	classic_panel.add_child(classic_button)

	var footer := Label.new()
	footer.position = Vector2(38, 326)
	footer.text = "2.5D integration is in progress · both modes use WASD / arrow keys"
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color("#93a7a1"))
	add_child(footer)

	isometric_button.grab_focus.call_deferred()


func _make_mode_panel(panel_position: Vector2, eyebrow: String, heading: String, body: String, tint: Color) -> Panel:
	var panel := Panel.new()
	panel.position = panel_position
	panel.size = Vector2(268, 178)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#202c2d")
	style.border_color = tint.lightened(0.25)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	panel.add_theme_stylebox_override("panel", style)

	var eyebrow_label := Label.new()
	eyebrow_label.position = Vector2(18, 15)
	eyebrow_label.text = eyebrow
	eyebrow_label.add_theme_font_size_override("font_size", 10)
	eyebrow_label.add_theme_color_override("font_color", tint.lightened(0.48))
	panel.add_child(eyebrow_label)

	var heading_label := Label.new()
	heading_label.position = Vector2(18, 36)
	heading_label.text = heading
	heading_label.add_theme_font_size_override("font_size", 19)
	heading_label.add_theme_color_override("font_color", Color("#f1e6c7"))
	panel.add_child(heading_label)

	var body_label := Label.new()
	body_label.position = Vector2(18, 70)
	body_label.text = body
	body_label.add_theme_font_size_override("font_size", 11)
	body_label.add_theme_color_override("font_color", Color("#bdcbc5"))
	panel.add_child(body_label)
	return panel


func _make_button(label_text: String, tint: Color) -> Button:
	var button := Button.new()
	button.size = Vector2(232, 29)
	button.text = label_text
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("#1d2728"))
	button.add_theme_color_override("font_hover_color", Color("#11191a"))
	button.add_theme_color_override("font_focus_color", Color("#11191a"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = tint
	normal.corner_radius_top_left = 2
	normal.corner_radius_top_right = 2
	normal.corner_radius_bottom_left = 2
	normal.corner_radius_bottom_right = 2
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = tint.lightened(0.16)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", hover)
	return button


func _open_isometric() -> void:
	get_tree().change_scene_to_file(ISOMETRIC_SCENE)


func _open_classic() -> void:
	get_tree().change_scene_to_file(CLASSIC_SCENE)


func get_launch_metrics() -> Dictionary:
	return {
		"isometric_scene": ISOMETRIC_SCENE,
		"classic_scene": CLASSIC_SCENE,
		"mode_count": 2,
		"isometric_button_present": isometric_button != null,
		"classic_button_present": classic_button != null,
	}
