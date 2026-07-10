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
	var scene_resource: PackedScene = load("res://scenes/main.tscn")
	var main := scene_resource.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	check(main.current_world != null, "Main world is created")
	check(main.current_world.world_id == "shanghai", "A new game starts in Shanghai")
	check(main.current_world.get_node_or_null("WukangMansion") != null, "Shanghai contains Wukang Mansion")
	check(main.current_world.get_node_or_null("OrientalPearlTower") != null, "Shanghai contains the Oriental Pearl Tower")
	check(main.player != null and main.camera_rig != null, "Player and diagonal camera are active")

	main._on_travel_finished("seattle")
	await get_tree().process_frame
	await get_tree().process_frame
	check(main.current_world.world_id == "seattle", "Travel loads Seattle")
	check(main.current_world.get_node_or_null("PikePlaceMarket") != null, "Seattle contains Pike Place Market")
	check(main.current_world.get_node_or_null("SpaceNeedle") != null, "Seattle contains the Space Needle")
	check(main.current_world.get_node_or_null("SeattleAquarium") != null, "Seattle contains the Aquarium")
	check(main.current_world.get_node_or_null("SeattleGreatWheel") != null, "Seattle contains the Great Wheel")
	check(main.current_world.friends.size() == 2, "Kent and Joey appear in Seattle")

	GameState.invite_friends()
	main.current_world.refresh_friend_following()
	check(main.current_world.friends[0].follow_target == main.player, "Invited friends follow the player")

	var original_card_id := str(GameState.player_cards[0].id)
	var trade_result := GameState.trade_first_cards("kent")
	check(bool(trade_result.ok), "A basic card trade succeeds")
	check(str(GameState.player_cards[0].id) != original_card_id, "The card collection changes after trade")

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
