extends Node


func _ready() -> void:
	var target_world := "shanghai"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--world="):
			target_world = argument.trim_prefix("--world=")
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
