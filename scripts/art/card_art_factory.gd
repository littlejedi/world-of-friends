class_name CardArtFactory
extends RefCounted

const WIDTH := 32
const HEIGHT := 40
const COLORWAYS := {
	"spark_mouse": ["#f6d76f", "#e99b38", "#66443a"],
	"harbor_otter": ["#74b9c4", "#9b6947", "#f0d3a1"],
	"bamboo_dragon": ["#8fc77a", "#3f8b62", "#f0d06a"],
	"rain_fox": ["#7897bd", "#d56f51", "#f2d39c"],
	"needle_owl": ["#8fc3c5", "#8a684d", "#f2c963"],
	"pearl_sprite": ["#d59ac2", "#f0dce9", "#c95683"],
	"market_fish": ["#63a9bf", "#e98355", "#f5d16d"],
	"shanghai_skyline": ["#e9b77a", "#b84f58", "#f2d8a7"],
	"seattle_sound": ["#78aeb8", "#3e7186", "#e0c06b"]
}
const DEFAULT_COLORWAYS := [
	["#84a6bf", "#d17a5d", "#f1d18a"],
	["#9ab982", "#5b8e68", "#ead08a"],
	["#b897bd", "#756192", "#efc879"]
]


static func create(card_id: String) -> Texture2D:
	var palette: Array = COLORWAYS.get(card_id, DEFAULT_COLORWAYS[absi(card_id.hash()) % DEFAULT_COLORWAYS.size()])
	var sky := Color(str(palette[0]))
	var subject := Color(str(palette[1]))
	var accent := Color(str(palette[2]))
	var image := Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color("#101825"))
	_rect(image, 1, 1, 30, 38, Color("#d9b45f"))
	_rect(image, 2, 2, 28, 36, Color("#1b293b"))
	_rect(image, 3, 3, 26, 4, subject)
	_rect(image, 3, 8, 26, 21, sky)
	_rect(image, 3, 23, 26, 6, sky.darkened(0.28))
	if card_id == "shanghai_skyline":
		_draw_shanghai(image, subject, accent)
	elif card_id == "seattle_sound":
		_draw_seattle(image, subject, accent)
	else:
		_draw_creature(image, card_id, subject, accent)
	_draw_card_marks(image, card_id, accent)
	return ImageTexture.create_from_image(image)


static func _draw_creature(image: Image, card_id: String, subject: Color, accent: Color) -> void:
	if card_id == "market_fish":
		_rect(image, 10, 14, 12, 7, subject)
		_rect(image, 7, 16, 3, 3, subject.darkened(0.12))
		_rect(image, 22, 15, 3, 5, accent)
		_pixel(image, 19, 16, Color("#172133"))
		_rect(image, 13, 21, 5, 2, accent.darkened(0.1))
		return
	var body_x := 11
	var body_y := 17
	_rect(image, body_x, body_y, 10, 8, subject)
	_rect(image, 12, 11, 8, 7, subject.lightened(0.08))
	_rect(image, 14, 18, 4, 5, accent)
	_pixel(image, 14, 14, Color("#172133"))
	_pixel(image, 18, 14, Color("#172133"))
	match card_id:
		"spark_mouse":
			_rect(image, 11, 9, 3, 3, subject)
			_rect(image, 18, 9, 3, 3, subject)
			_draw_tail(image, 21, 20, accent, true)
		"harbor_otter":
			_rect(image, 11, 10, 3, 2, subject.darkened(0.08))
			_rect(image, 18, 10, 3, 2, subject.darkened(0.08))
			_draw_tail(image, 10, 21, subject.darkened(0.15), false)
		"bamboo_dragon":
			_rect(image, 12, 8, 2, 4, accent)
			_rect(image, 18, 8, 2, 4, accent)
			_rect(image, 8, 18, 3, 5, subject.darkened(0.12))
			_rect(image, 21, 18, 3, 5, subject.darkened(0.12))
		"rain_fox":
			_rect(image, 11, 8, 3, 4, subject)
			_rect(image, 18, 8, 3, 4, subject)
			_pixel(image, 12, 8, accent)
			_pixel(image, 19, 8, accent)
			_draw_tail(image, 21, 19, accent, true)
		"needle_owl":
			_rect(image, 9, 16, 3, 7, subject.darkened(0.15))
			_rect(image, 20, 16, 3, 7, subject.darkened(0.15))
			_rect(image, 13, 13, 3, 3, accent)
			_rect(image, 17, 13, 3, 3, accent)
			_pixel(image, 14, 14, Color("#172133"))
			_pixel(image, 18, 14, Color("#172133"))
		"pearl_sprite":
			_rect(image, 10, 12, 2, 2, accent)
			_rect(image, 21, 10, 2, 2, accent)
			_rect(image, 22, 20, 2, 2, subject)
		_:
			_rect(image, 11, 9, 3, 3, subject)
			_rect(image, 18, 9, 3, 3, subject)


static func _draw_shanghai(image: Image, subject: Color, accent: Color) -> void:
	_rect(image, 5, 18, 5, 8, subject.darkened(0.18))
	_rect(image, 11, 15, 4, 11, subject)
	_rect(image, 23, 13, 2, 13, accent.lightened(0.15))
	_rect(image, 19, 20, 3, 6, subject.darkened(0.08))
	_rect(image, 23, 10, 2, 4, accent)
	_rect(image, 22, 13, 4, 4, subject)
	_rect(image, 23, 8, 2, 3, accent)
	_pixel(image, 24, 6, accent.lightened(0.2))


static func _draw_seattle(image: Image, subject: Color, accent: Color) -> void:
	_rect(image, 3, 23, 26, 6, Color("#326d86"))
	_rect(image, 15, 11, 2, 15, accent.lightened(0.25))
	_rect(image, 11, 14, 10, 2, subject)
	_rect(image, 12, 12, 8, 2, accent)
	_rect(image, 15, 8, 2, 5, accent.lightened(0.25))
	_rect(image, 7, 20, 5, 6, subject.darkened(0.18))
	_rect(image, 21, 18, 4, 8, subject)


static func _draw_card_marks(image: Image, card_id: String, accent: Color) -> void:
	var marks := 1 + absi(card_id.hash()) % 3
	for index in range(marks):
		_rect(image, 5 + index * 5, 33, 3, 3, accent)
	_rect(image, 23, 33, 4, 2, Color("#8fa5b3"))
	_rect(image, 23, 36, 4, 1, Color("#657989"))


static func _draw_tail(image: Image, start_x: int, start_y: int, color: Color, rising: bool) -> void:
	for step in range(5):
		var y: int = start_y - step if rising else start_y + floori(float(step) / 2.0)
		_pixel(image, start_x + step, y, color)
		if y + 1 < HEIGHT:
			_pixel(image, start_x + step, y + 1, color)


static func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	image.fill_rect(Rect2i(x, y, width, height), color)


static func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT:
		image.set_pixel(x, y, color)
