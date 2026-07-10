extends Node

const SAVE_PATH := "user://world_of_friends_save.json"

var current_world: String = "shanghai"
var has_arrived_seattle: bool = false
var friends_in_party: bool = false
var player_cards: Array = []
var friend_cards: Dictionary = {}


func _ready() -> void:
	load_game()


func defaults() -> Dictionary:
	return {
		"current_world": "shanghai",
		"has_arrived_seattle": false,
		"friends_in_party": false,
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
	var available: Array = friend_cards.get(friend_id, [])
	if player_cards.is_empty() or available.is_empty():
		return {"ok": false, "message": "There are no cards available for this trade."}
	var offered: Dictionary = player_cards.pop_front()
	var received: Dictionary = available.pop_front()
	player_cards.append(received)
	available.append(offered)
	friend_cards[friend_id] = available
	save_game()
	return {
		"ok": true,
		"message": "You traded %s for %s." % [offered.name, received.name]
	}


func reset_progress() -> void:
	apply_data(defaults())
	save_game()
