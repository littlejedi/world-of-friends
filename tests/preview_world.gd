extends Node


func _ready() -> void:
	var target_world := "shanghai"
	var focus := "default"
	var modal_preview := "none"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--world="):
			target_world = argument.trim_prefix("--world=")
		elif argument.begins_with("--focus="):
			focus = argument.trim_prefix("--focus=")
		elif argument.begins_with("--modal="):
			modal_preview = argument.trim_prefix("--modal=")
	GameState.reset_progress()
	var main: Node = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().process_frame
	await get_tree().process_frame
	if target_world != "shanghai":
		GameState.has_arrived_seattle = true
		main._load_world(target_world, false)
		main.hud.toast_timer.stop()
		main.hud.toast_label.visible = false
	if focus == "waterfront":
		main.player.global_position = Vector3(0, 0.08, 8.2)
	if modal_preview == "trade":
		main.hud.show_friend_menu("kent", "Kent")
		main.hud._trade_card()
	elif modal_preview == "collection":
		main.hud.show_collection()
	elif modal_preview == "pause":
		main.hud.show_pause_menu()
