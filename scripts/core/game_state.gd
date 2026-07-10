extends Node

const SAVE_PATH := "user://world_of_friends_save.json"

var current_world: String = "shanghai"
var has_arrived_seattle: bool = false
var friends_in_party: bool = false
var player_cards: Array = []
var friend_cards: Dictionary = {}
var world_positions: Dictionary = {}
var card_texture_cache: Dictionary = {}


func _ready() -> void:
	load_game()


func defaults() -> Dictionary:
	return {
		"current_world": "shanghai",
		"has_arrived_seattle": false,
		"friends_in_party": false,
		"world_positions": {},
		"player_cards": [
			{"id": "spark_mouse", "name": "Spark Mouse", "rarity": "Rare"},
			{"id": "harbor_otter", "name": "Harbor Otter", "rarity": "Common"},
			{"id": "bamboo_dragon", "name": "Bamboo Dragon", "rarity": "Uncommon"}
		],
		"friend_cards": {
			"kent": [
				{"id": "rain_fox", "name": "Rain Fox", "rarity": "Uncommon"},
				{"id": "needle_owl", "name": "Needle Owl", "rarity": "Rare"}
			],
			"joey": [
				{"id": "pearl_sprite", "name": "Pearl Sprite", "rarity": "Rare"},
				{"id": "market_fish", "name": "Market Fish", "rarity": "Common"}
			]
		}
	}


func apply_data(data: Dictionary) -> void:
	var fallback := defaults()
	current_world = str(data.get("current_world", fallback.current_world))
	has_arrived_seattle = bool(data.get("has_arrived_seattle", fallback.has_arrived_seattle))
	friends_in_party = bool(data.get("friends_in_party", fallback.friends_in_party))
	player_cards = data.get("player_cards", fallback.player_cards).duplicate(true)
	friend_cards = data.get("friend_cards", fallback.friend_cards).duplicate(true)
	world_positions = data.get("world_positions", fallback.world_positions).duplicate(true)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		apply_data(defaults())
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		apply_data(defaults())
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		apply_data(parsed)
	else:
		apply_data(defaults())


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save World of Friends progress.")
		return
	var data := {
		"current_world": current_world,
		"has_arrived_seattle": has_arrived_seattle,
		"friends_in_party": friends_in_party,
		"world_positions": world_positions,
		"player_cards": player_cards,
		"friend_cards": friend_cards
	}
	file.store_string(JSON.stringify(data, "\t"))


func set_world(world_id: String) -> void:
	current_world = world_id
	save_game()


func invite_friends() -> void:
	friends_in_party = true
	save_game()


func mark_seattle_arrival() -> bool:
	if has_arrived_seattle:
		return false
	has_arrived_seattle = true
	save_game()
	return true


func trade_first_cards(friend_id: String) -> Dictionary:
	return trade_cards(friend_id, 0, 0)


func trade_cards(friend_id: String, player_index: int, friend_index: int) -> Dictionary:
	var available: Array = friend_cards.get(friend_id, [])
	if player_cards.is_empty() or available.is_empty():
		return {"ok": false, "message": "There are no cards available for this trade."}
	if player_index < 0 or player_index >= player_cards.size() or friend_index < 0 or friend_index >= available.size():
		return {"ok": false, "message": "That card selection is no longer available."}
	var offered: Dictionary = player_cards[player_index]
	var received: Dictionary = available[friend_index]
	player_cards[player_index] = received
	available[friend_index] = offered
	friend_cards[friend_id] = available
	save_game()
	return {
		"ok": true,
		"message": "You traded %s for %s." % [offered.name, received.name]
	}


func set_player_position(world_id: String, position: Vector3, write_to_disk: bool = true) -> void:
	world_positions[world_id] = [position.x, position.y, position.z]
	if write_to_disk:
		save_game()


func get_player_position(world_id: String) -> Variant:
	var stored: Variant = world_positions.get(world_id)
	if stored is Array and stored.size() == 3:
		return Vector3(float(stored[0]), float(stored[1]), float(stored[2]))
	return null


func get_card_texture(card_id: String) -> Texture2D:
	if card_texture_cache.has(card_id):
		return card_texture_cache[card_id]
	for extension in ["png", "jpg", "jpeg", "webp"]:
		var resource_path := "res://private_assets/cards/%s.%s" % [card_id, extension]
		if ResourceLoader.exists(resource_path):
			var resource: Variant = load(resource_path)
			if resource is Texture2D:
				var resource_thumbnail := _make_card_thumbnail(resource.get_image())
				card_texture_cache[card_id] = resource_thumbnail
				return resource_thumbnail
		var user_path := "user://cards/%s.%s" % [card_id, extension]
		if FileAccess.file_exists(user_path):
			var image := Image.load_from_file(user_path)
			if not image.is_empty():
				var texture := _make_card_thumbnail(image)
				card_texture_cache[card_id] = texture
				return texture
	card_texture_cache[card_id] = null
	return null


func _make_card_thumbnail(source: Image) -> Texture2D:
	if source.is_empty():
		return null
	var thumbnail := source.duplicate()
	var target_height := 28
	var target_width := maxi(18, roundi(float(source.get_width()) / maxf(1.0, float(source.get_height())) * target_height))
	thumbnail.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(thumbnail)


func reset_progress() -> void:
	apply_data(defaults())
	save_game()
