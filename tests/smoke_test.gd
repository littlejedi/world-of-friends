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
	GameState.discover_landmark("wukang_mansion")
	GameState.discover_landmark("oriental_pearl")
	GameState.discover_landmark("xuhui_riverside")
	GameState.claim_city_guide_reward("shanghai")
	GameState.apply_data(GameState.defaults())
	GameState.load_game()
	check(GameState.get_player_position("shanghai").distance_to(disk_position) < 0.01, "Player position survives a disk save and reload")
	check(GameState.is_landmark_discovered("wukang_mansion"), "Landmark discoveries survive a disk save and reload")
	check(GameState.has_claimed_city_reward("shanghai") and str(GameState.player_cards.back().id) == "shanghai_skyline", "City souvenir rewards survive a disk save and reload")
	GameState.reset_progress()
	var scene_resource: PackedScene = load("res://scenes/main.tscn")
	var main := scene_resource.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	check(main.current_world != null, "Main world is created")
	check(GameState.get_landmark_entries("shanghai").size() == 3 and GameState.get_landmark_entries("seattle").size() == 4, "City guide metadata covers both worlds")
	check(not bool(GameState.claim_city_guide_reward("shanghai").ok), "An incomplete city guide cannot claim its souvenir")
	var generated_card := GameState.get_card_texture("spark_mouse")
	var generated_card_image := generated_card.get_image()
	check(generated_card_image.get_width() == 32 and generated_card_image.get_height() == 40, "Built-in cards receive generated pixel artwork")
	check(GameState.get_card_texture("spark_mouse") == generated_card, "Generated card artwork is cached")
	var souvenir_card_image := GameState.get_card_texture("shanghai_skyline").get_image()
	check(souvenir_card_image.get_pixel(3, 3) != generated_card_image.get_pixel(3, 3), "Souvenir cards receive distinct city artwork")
	check(main.gameplay_audio != null, "Gameplay sound system is created")
	var footstep_profiles_complete: bool = main.gameplay_audio.footstep_streams.size() == 4
	for surface in ["road", "ground", "promenade", "pier"]:
		footstep_profiles_complete = footstep_profiles_complete and (main.gameplay_audio.footstep_streams.get(surface, []) as Array).size() == 2
	check(footstep_profiles_complete, "Alternating footsteps are synthesized for every surface")
	main._on_player_step()
	check(main.gameplay_audio.footstep_player.stream is AudioStreamWAV, "Player steps trigger a generated sound")
	for sample in [
		{"position": Vector3(0, 0.08, -3.5), "surface": "road"},
		{"position": Vector3(-18, 0.08, 4.5), "surface": "ground"},
		{"position": Vector3(-8, 0.08, 9.6), "surface": "promenade"}
	]:
		main.player.global_position = sample.position
		main._on_player_step()
		check(main.gameplay_audio.last_footstep_surface == sample.surface, "Shanghai %s selects its own footstep profile" % sample.surface)
	main.gameplay_audio.play_interaction()
	check(main.gameplay_audio.effect_player.stream == main.gameplay_audio.interaction_stream, "Interactions trigger a generated chime")
	check(main.current_world.world_id == "shanghai", "A new game starts in Shanghai")
	check(main.current_world.get_node_or_null("WukangMansion") != null, "Shanghai contains Wukang Mansion")
	check(main.current_world.get_node_or_null("WukangMansion/FlatironNose") is MeshInstance3D, "Wukang Mansion has a modeled flatiron silhouette")
	check(main.current_world.get_node_or_null("OrientalPearlTower") != null, "Shanghai contains the Oriental Pearl Tower")
	check(main.current_world.get_node_or_null("OrientalPearlTower/Support0") != null and main.current_world.get_node_or_null("OrientalPearlTower/LowerDeck") != null, "Oriental Pearl has tripod supports and deck rings")
	check(main.current_world.get_node_or_null("HuangpuRiver") != null, "Shanghai contains animated river water")
	check(main.current_world.get_node_or_null("HuangpuRiverBoat") != null, "Shanghai river traffic is active")
	check(main.current_world.get_node_or_null("ShanghaiBirds") != null, "Shanghai has ambient bird movement")
	check(main.current_world.get_node_or_null("ShanghaiWalkerA") != null, "Shanghai has ambient pedestrians")
	var shanghai_audio: AmbientAudio = main.current_world.get_node("AmbientAudio")
	check(shanghai_audio.stream is AudioStreamWAV, "Shanghai ambience is synthesized as a browser-safe WAV loop")
	check((shanghai_audio.stream as AudioStreamWAV).data.size() > 300000, "Shanghai ambience contains generated stereo audio")
	main._on_ambient_audio_toggle()
	check(not GameState.ambient_audio_enabled and not shanghai_audio.playback_enabled and not main.gameplay_audio.playback_enabled, "All sound can be muted and persisted")
	main._on_ambient_audio_toggle()
	check(GameState.ambient_audio_enabled and shanghai_audio.playback_enabled and main.gameplay_audio.playback_enabled, "All sound can be restored")
	check(main.current_world.get_node_or_null("WukangMansionPlaque") != null, "Shanghai landmarks can be inspected")
	main.current_world.get_node("WukangMansionPlaque").interact(main.player)
	check(main.hud.is_modal_open(), "Inspecting a landmark opens its information panel")
	check(GameState.is_landmark_discovered("wukang_mansion") and GameState.get_discovery_count("shanghai") == 1, "Inspecting a landmark records its discovery")
	main.hud.close_modal()
	main.hud.show_city_guide()
	await get_tree().process_frame
	check(main.hud.modal_content.find_children("Guide_*", "PanelContainer", true, false).size() == 3, "Shanghai city guide displays all landmark entries")
	main.hud.close_modal()
	main.current_world.get_node("WukangMansionPlaque").interact(main.player)
	check(GameState.get_discovery_count("shanghai") == 1, "Revisiting a landmark does not duplicate progress")
	main.hud.close_modal()
	main.current_world.get_node("OrientalPearlTowerPlaque").interact(main.player)
	main.hud.close_modal()
	main.current_world.get_node("XuhuiRiversidePlaque").interact(main.player)
	check(GameState.has_claimed_city_reward("shanghai") and str(GameState.player_cards.back().id) == "shanghai_skyline", "Completing Shanghai awards its souvenir card")
	main.hud.close_modal()
	main.current_world.get_node("XuhuiRiversidePlaque").interact(main.player)
	check(GameState.player_cards.size() == 4, "Shanghai souvenir can only be awarded once")
	main.hud.close_modal()
	check(main.player != null and main.camera_rig != null, "Player and diagonal camera are active")
	var saved_position := Vector3(-2.4, 0.08, -2.2)
	GameState.set_player_position("shanghai", saved_position, false)
	main._load_world("shanghai", false, true)
	await get_tree().process_frame
	var restored_planar := Vector2(main.player.global_position.x, main.player.global_position.z)
	var expected_planar := Vector2(saved_position.x, saved_position.z)
	check(restored_planar.distance_to(expected_planar) < 0.01, "Per-world player position is restored")

	main._begin_travel("seattle")
	check(main.gameplay_audio.travel_active and main.gameplay_audio.travel_player.stream == main.gameplay_audio.travel_stream, "Shuttle travel starts its engine loop")
	check(not main.travel_cutscene.party_traveling and main.travel_cutscene.passenger_label.text.contains("YOU"), "First shuttle trip shows the player traveling alone")
	main.travel_cutscene.visible = false
	main._on_travel_finished("seattle")
	await get_tree().process_frame
	await get_tree().process_frame
	check(not main.gameplay_audio.travel_active and main.gameplay_audio.effect_player.stream == main.gameplay_audio.arrival_stream, "Shuttle arrival stops the engine and plays a chime")
	check(main.current_world.world_id == "seattle", "Travel loads Seattle")
	check(main.current_world.get_node_or_null("PikePlaceMarket") != null, "Seattle contains Pike Place Market")
	check(main.current_world.get_node_or_null("PikePlaceMarket/MarketClock") != null, "Pike Place Market includes its landmark clock")
	check(main.current_world.get_node_or_null("SpaceNeedle") != null, "Seattle contains the Space Needle")
	check(main.current_world.get_node_or_null("SpaceNeedle/Leg0") != null and main.current_world.get_node_or_null("SpaceNeedle/DeckGlass") != null, "Space Needle has splayed legs and a layered saucer")
	check(main.current_world.get_node_or_null("SeattleAquarium") != null, "Seattle contains the Aquarium")
	check(main.current_world.get_node_or_null("SeattleGreatWheel") != null, "Seattle contains the Great Wheel")
	var wheel_rotor: RotationAnimator = main.current_world.get_node("SeattleGreatWheel/WheelRotor")
	var wheel_rotation_before: float = wheel_rotor.rotation.z
	wheel_rotor._process(1.0)
	check(wheel_rotor.rotation.z > wheel_rotation_before, "Seattle Great Wheel rotates")
	check(main.current_world.get_node_or_null("ElliottBay") != null, "Seattle contains animated bay water")
	check(main.current_world.get_node_or_null("ElliottBayFerry") != null, "Seattle ferry traffic is active")
	check(main.current_world.get_node_or_null("SeattleGulls") != null, "Seattle has ambient gull movement")
	check(main.current_world.get_node_or_null("SeattleWalkerA") != null, "Seattle has ambient pedestrians")
	main.player.global_position = Vector3(0, 0.08, 9.6)
	main._on_player_step()
	check(main.gameplay_audio.last_footstep_surface == "pier", "Seattle waterfront selects the pier footstep profile")
	check(main.current_world.friends.size() == 2, "Kent and Joey appear in Seattle")
	main.hud.close_modal()
	main.current_world.get_node("SeattleAquariumPlaque").interact(main.player)
	check(GameState.is_landmark_discovered("seattle_aquarium") and GameState.get_discovery_count("seattle") == 1, "Seattle discoveries use their own guide progress")
	main.hud.close_modal()
	for plaque_name in ["PikePlaceMarketPlaque", "SpaceNeedlePlaque", "SeattleGreatWheelPlaque"]:
		main.current_world.get_node(plaque_name).interact(main.player)
		main.hud.close_modal()
	check(GameState.has_claimed_city_reward("seattle") and str(GameState.player_cards.back().id) == "seattle_sound", "Completing Seattle awards its souvenir card")
	check(GameState.player_cards.size() == 5, "Both city souvenirs join the card collection")
	main.hud.show_friend_menu("kent", "Kent")
	main.hud._show_hello()
	check(not main.hud.is_modal_open(), "Greeting closes the conversation panel so the animation stays visible")
	check(main.player.wave_tween != null, "Saying hello makes the player wave")
	check(main.current_world.friends[0].wave_tween != null, "Saying hello triggers a friend reaction")
	check(main.player.speech_bubble.visible and main.player.speech_bubble.text == "HELLO!", "The player greeting appears in the world")
	check(main.current_world.friends[0].speech_bubble.visible and main.current_world.friends[0].speech_bubble.text == "HI!", "The friend answers with an in-world greeting")
	var player_to_kent: Vector3 = main.current_world.friends[0].global_position - main.player.global_position
	player_to_kent.y = 0.0
	check((-main.player.global_basis.z).dot(player_to_kent.normalized()) > 0.98, "The player turns toward the greeted friend")
	main._on_all_friends_hello()
	check(main.current_world.friends[1].wave_tween != null, "A group hello makes every friend wave")

	GameState.invite_friends()
	main.current_world.refresh_friend_following()
	check(main.current_world.friends[0].follow_target == main.player, "Invited friends follow the player")
	main.hud.show_ticket("shanghai")
	await get_tree().process_frame
	var ticket_mentions_friends := false
	for ticket_label in main.hud.modal_content.find_children("*", "Label", true, false):
		if str(ticket_label.text).contains("Kent and Joey"):
			ticket_mentions_friends = true
	check(ticket_mentions_friends, "Party ticket confirms Kent and Joey will board")
	main.hud.close_modal()
	for step in range(18):
		main.current_world.update_companion_trail(Vector3(float(step) * 0.42, 0.08, 3.0))
	check(main.current_world.companion_trail.size() > 10, "Companion breadcrumb trail records the player's route")
	check(main.current_world.friends[0].using_follow_point, "Companions follow breadcrumb points around corners")

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
	main.hud.show_collection()
	await get_tree().process_frame
	check(main.hud.modal_content.find_children("*", "PanelContainer", true, false).size() == GameState.player_cards.size(), "Collection viewer displays every owned card")
	main.hud.close_modal()
	main.hud.show_pause_menu()
	await get_tree().process_frame
	check(main.hud.modal_content.find_children("*", "Button", true, false).size() == 6, "Pause menu exposes resume, collection, guide, audio, save, and quit actions")
	main.hud.close_modal()

	main._begin_travel("shanghai")
	check(main.travel_cutscene.party_traveling and main.travel_cutscene.passenger_label.text.contains("KENT & JOEY"), "Return shuttle visibly includes Kent and Joey")
	main.travel_cutscene.visible = false
	main._on_travel_finished("shanghai")
	await get_tree().process_frame
	check(main.current_world.world_id == "shanghai", "Return travel loads Shanghai")
	check(main.current_world.friends.size() == 2, "Kent and Joey travel back to Shanghai")
	check(main.hud.toast_label.text.contains("with Kent and Joey"), "Party arrival confirms the friends reached Shanghai")
	GameState.claimed_city_rewards.erase("shanghai")
	for card_index in range(GameState.player_cards.size() - 1, -1, -1):
		if str(GameState.player_cards[card_index].id) == "shanghai_skyline":
			GameState.player_cards.remove_at(card_index)
	main.current_world.get_node("WukangMansionPlaque").interact(main.player)
	check(GameState.has_claimed_city_reward("shanghai"), "A guide completed in an older save can claim its new souvenir")
	main.hud.close_modal()

	GameState.reset_progress()
	main.current_world.stop_ambient_audio()
	main.gameplay_audio.shutdown()
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if failures.is_empty():
		print("SMOKE TEST COMPLETE: all checks passed")
		get_tree().quit(0)
	else:
		print("SMOKE TEST COMPLETE: %d failure(s)" % failures.size())
		get_tree().quit(1)
