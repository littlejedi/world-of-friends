class_name TravelCutscene
extends Control

signal finished(destination: String)

const DURATION := 6.0

var destination: String = "seattle"
var origin: String = "shanghai"
var elapsed: float = 0.0
var stars: Array[Vector2] = []
var title_label: Label
var subtitle_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var random := RandomNumberGenerator.new()
	random.seed = 20260710
	for _index in range(90):
		stars.append(Vector2(random.randf_range(0, 640), random.randf_range(0, 360)))
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.anchor_left = 0.5
	title_label.anchor_right = 0.5
	title_label.offset_left = -260
	title_label.offset_right = 260
	title_label.offset_top = 26
	title_label.offset_bottom = 62
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color("#fff0b5"))
	add_child(title_label)
	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.anchor_left = 0.5
	subtitle_label.anchor_right = 0.5
	subtitle_label.anchor_top = 1.0
	subtitle_label.anchor_bottom = 1.0
	subtitle_label.offset_left = -260
	subtitle_label.offset_right = 260
	subtitle_label.offset_top = -54
	subtitle_label.offset_bottom = -22
	subtitle_label.text = "Traveling through space  •  press Space to skip"
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color("#cbd8ff"))
	add_child(subtitle_label)


func start_trip(origin_id: String, destination_id: String) -> void:
	origin = origin_id
	destination = destination_id
	elapsed = 0.0
	title_label.text = "%s  →  %s" % [origin.capitalize(), destination.capitalize()]
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	if Input.is_action_just_pressed("ui_accept") and elapsed > 0.5:
		elapsed = DURATION
	queue_redraw()
	if elapsed >= DURATION:
		visible = false
		finished.emit(destination)


func _draw() -> void:
	if not visible:
		return
	var viewport_size := size
	if viewport_size.x <= 1.0:
		viewport_size = Vector2(640, 360)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#070a1c"))
	var progress := clampf(elapsed / DURATION, 0.0, 1.0)
	for index in range(stars.size()):
		var star := stars[index]
		var shifted_x := fposmod(star.x - progress * (70.0 + float(index % 7) * 18.0), 640.0)
		var radius := 0.6 + float(index % 3) * 0.45
		draw_circle(Vector2(shifted_x, star.y), radius, Color(0.72, 0.82, 1.0, 0.85))
	var planet_color := Color("#5b91bb") if destination == "seattle" else Color("#c96c5b")
	var planet_position := Vector2(570.0 - (1.0 - progress) * 75.0, 280.0)
	draw_circle(planet_position, 62.0 * progress + 8.0, Color(planet_color, 0.9))
	draw_circle(planet_position + Vector2(-18, -12), 12.0 * progress, Color("#6ba66c"))
	var shuttle_x := lerpf(-90.0, 730.0, progress)
	var shuttle_y := 190.0 + sin(progress * TAU * 1.5) * 12.0
	var shuttle_points := PackedVector2Array([
		Vector2(shuttle_x - 42, shuttle_y + 13),
		Vector2(shuttle_x + 34, shuttle_y + 13),
		Vector2(shuttle_x + 52, shuttle_y),
		Vector2(shuttle_x + 34, shuttle_y - 13),
		Vector2(shuttle_x - 42, shuttle_y - 13)
	])
	draw_colored_polygon(shuttle_points, Color("#e8edf0"))
	draw_rect(Rect2(Vector2(shuttle_x - 18, shuttle_y - 9), Vector2(15, 8)), Color("#68c7e1"))
	draw_rect(Rect2(Vector2(shuttle_x + 2, shuttle_y - 9), Vector2(15, 8)), Color("#68c7e1"))
	var flame_length := 15.0 + sin(elapsed * 15.0) * 5.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(shuttle_x - 42, shuttle_y - 7),
		Vector2(shuttle_x - 42 - flame_length, shuttle_y),
		Vector2(shuttle_x - 42, shuttle_y + 7)
	]), Color("#f2a64b"))
