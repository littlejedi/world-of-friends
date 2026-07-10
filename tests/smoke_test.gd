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
	check(main.gameplay_audio != null, "Gameplay sound system is created")
	check(main.gameplay_audio.footstep_streams.size() == 2, "Alternating footsteps are synthesized")
	main._on_player_step()
	check(main.gameplay_audio.footstep_player.stream is AudioStreamWAV, "Player steps trigger a generated sound")
	main.gameplay_audio.play_interaction()
	check(main.gameplay_audio.effect_player.stream == main.gameplay_audio.interaction_stream, "Interactions trigger a generated chime")
	check(main.current_world.world_id == "shanghai", "A new game starts in Shanghai")
	check(main.current_world.get_node_or_null("WukangMansion") != null, "Shanghai contains Wukang Mansion")
	check(main.current_world.get_node_or_null("OrientalPearlTower") != null, "Shanghai contains the Oriental Pearl Tower")
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
	main.travel_cutscene.visible = false
	main._on_travel_finished("seattle")
	await get_tree().process_frame
	await get_tree().process_frame
	check(not main.gameplay_audio.travel_active and main.gameplay_audio.effect_player.stream == main.gameplay_audio.arrival_stream, "Shuttle arrival stops the engine and plays a chime")
	check(main.current_world.world_id == "seattle", "Travel loads Seattle")
	check(main.current_world.get_node_or_null("PikePlaceMarket") != null, "Seattle contains Pike Place Market")
	check(main.current_world.get_node_or_null("SpaceNeedle") != null, "Seattle contains the Space Needle")
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
	main.current_world.wave_friend("kent")
	check(main.current_world.friends[0].wave_tween != null, "Saying hello triggers a friend reaction")

	GameState.invite_friends()
	main.current_world.refresh_friend_following()
	check(main.current_world.friends[0].follow_target == main.player, "Invited friends follow the player")
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

	main._on_travel_finished("shanghai")
	await get_tree().process_frame
	check(main.current_world.world_id == "shanghai", "Return travel loads Shanghai")
	check(main.current_world.friends.size() == 2, "Kent and Joey travel back to Shanghai")
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
