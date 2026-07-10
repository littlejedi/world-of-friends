extends Node

var failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: %s" % message)


func _run() -> void:
	GameState.reset_progress()
	var disk_position := Vector3(1.25, 0.08, -3.5)
	GameState.set_player_position("shanghai", disk_position)
	GameState.apply_data(GameState.defaults())
	GameState.load_game()
	check(GameState.get_player_position("shanghai").distance_to(disk_position) < 0.01, "Player position survives a disk save and reload")
	GameState.reset_progress()
	var scene_resource: PackedScene = load("res://scenes/main.tscn")
	var main := scene_resource.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	check(main.current_world != null, "Main world is created")
	check(main.current_world.world_id == "shanghai", "A new game starts in Shanghai")
	check(main.current_world.get_node_or_null("WukangMansion") != null, "Shanghai contains Wukang Mansion")
	check(main.current_world.get_node_or_null("OrientalPearlTower") != null, "Shanghai contains the Oriental Pearl Tower")
	check(main.current_world.get_node_or_null("HuangpuRiver") != null, "Shanghai contains animated river water")
	check(main.current_world.get_node_or_null("WukangMansionPlaque") != null, "Shanghai landmarks can be inspected")
	main.current_world.get_node("WukangMansionPlaque").interact(main.player)
	check(main.hud.is_modal_open(), "Inspecting a landmark opens its information panel")
	main.hud.close_modal()
	check(main.player != null and main.camera_rig != null, "Player and diagonal camera are active")
	var saved_position := Vector3(-2.4, 0.08, -2.2)
	GameState.set_player_position("shanghai", saved_position, false)
	main._load_world("shanghai", false, true)
	await get_tree().process_frame
	check(main.player.global_position.distance_to(saved_position) < 0.01, "Per-world player position is restored")

	main._on_travel_finished("seattle")
	await get_tree().process_frame
	await get_tree().process_frame
	check(main.current_world.world_id == "seattle", "Travel loads Seattle")
	check(main.current_world.get_node_or_null("PikePlaceMarket") != null, "Seattle contains Pike Place Market")
	check(main.current_world.get_node_or_null("SpaceNeedle") != null, "Seattle contains the Space Needle")
	check(main.current_world.get_node_or_null("SeattleAquarium") != null, "Seattle contains the Aquarium")
	check(main.current_world.get_node_or_null("SeattleGreatWheel") != null, "Seattle contains the Great Wheel")
	check(main.current_world.get_node_or_null("ElliottBay") != null, "Seattle contains animated bay water")
	check(main.current_world.friends.size() == 2, "Kent and Joey appear in Seattle")
	main.hud.close_modal()
	main.current_world.wave_friend("kent")
	check(main.current_world.friends[0].wave_tween != null, "Saying hello triggers a friend reaction")

	GameState.invite_friends()
	main.current_world.refresh_friend_following()
	check(main.current_world.friends[0].follow_target == main.player, "Invited friends follow the player")

	var original_player_card := str(GameState.player_cards[1].id)
	var original_kent_card := str(GameState.friend_cards.kent[1].id)
	var trade_result := GameState.trade_cards("kent", 1, 1)
	check(bool(trade_result.ok), "A selected card trade succeeds")
	check(str(GameState.player_cards[1].id) == original_kent_card, "The selected friend card enters the collection")
	check(str(GameState.friend_cards.kent[1].id) == original_player_card, "The selected player card moves to the friend")
	main.hud.show_friend_menu("kent", "Kent")
	main.hud._trade_card()
	await get_tree().process_frame
	check(main.hud.modal_content.find_children("*", "OptionButton", true, false).size() == 2, "Trade UI exposes both card selectors")
	main.hud.close_modal()

	main._on_travel_finished("shanghai")
	await get_tree().process_frame
	check(main.current_world.world_id == "shanghai", "Return travel loads Shanghai")
	check(main.current_world.friends.size() == 2, "Kent and Joey travel back to Shanghai")

	GameState.reset_progress()
	main.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("SMOKE TEST COMPLETE: all checks passed")
		get_tree().quit(0)
	else:
		print("SMOKE TEST COMPLETE: %d failure(s)" % failures.size())
		get_tree().quit(1)
