extends Node3D

const WorldScript = preload("res://scripts/gameplay/world_scene.gd")
const GameplayAudioScript = preload("res://scripts/art/gameplay_audio.gd")

@onready var world_root: Node3D = $WorldRoot
@onready var player: PlayerCharacter = $Player
@onready var camera_rig: DiagonalCameraRig = $CameraRig
@onready var hud: GameHUD = $HUD
@onready var travel_cutscene: TravelCutscene = $CutsceneLayer/TravelCutscene

var current_world: WorldScene
var travel_in_progress: bool = false
var position_save_timer: Timer
var gameplay_audio: Node


func _ready() -> void:
	player.interact_requested.connect(_on_interact_requested)
	player.step_taken.connect(_on_player_step)
	gameplay_audio = GameplayAudioScript.new()
	gameplay_audio.setup(GameState.ambient_audio_enabled)
	add_child(gameplay_audio)
	camera_rig.set_target(player)
	hud.travel_confirmed.connect(_begin_travel)
	hud.party_invited.connect(_on_party_invited)
	hud.friend_hello_requested.connect(_on_friend_hello)
	hud.all_friends_hello_requested.connect(_on_all_friends_hello)
	hud.save_requested.connect(_on_save_requested)
	hud.quit_requested.connect(_on_quit_requested)
	hud.ambient_audio_toggle_requested.connect(_on_ambient_audio_toggle)
	hud.modal_changed.connect(_on_modal_changed)
	travel_cutscene.finished.connect(_on_travel_finished)
	position_save_timer = Timer.new()
	position_save_timer.wait_time = 4.0
	position_save_timer.timeout.connect(_save_current_position)
	add_child(position_save_timer)
	position_save_timer.start()
	_load_world(GameState.current_world, false, true)


func _process(_delta: float) -> void:
	if current_world != null:
		current_world.update_companion_trail(player.global_position)
	if current_world == null or travel_in_progress or hud.is_modal_open():
		hud.set_prompt("")
		return
	var target := current_world.get_closest_interactable(player.global_position)
	if target != null and target.has_method("get_interaction_prompt"):
		hud.set_prompt(str(target.get_interaction_prompt()))
	else:
		hud.set_prompt("")


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_F8:
		GameState.reset_progress()
		_load_world("shanghai", false)
		hud.show_toast("Personal save reset. You are back in Shanghai.")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("collection") and not hud.is_modal_open() and not travel_in_progress:
		hud.show_collection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("audio_toggle") and not travel_in_progress:
		_on_ambient_audio_toggle()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and not hud.is_modal_open() and not travel_in_progress:
		hud.show_pause_menu()
		get_viewport().set_input_as_handled()


func _load_world(world_id: String, arriving: bool, restore_saved_position: bool = false) -> void:
	if current_world != null:
		current_world.stop_ambient_audio()
		current_world.free()
	current_world = WorldScript.new()
	current_world.name = world_id.capitalize()
	world_root.add_child(current_world)
	current_world.build(world_id, player)
	current_world.travel_requested.connect(_on_ticket_requested)
	current_world.friend_conversation_requested.connect(_on_friend_conversation)
	current_world.landmark_info_requested.connect(_on_landmark_info)
	var spawn_position := current_world.get_spawn_position(arriving)
	if restore_saved_position:
		var saved_position: Variant = GameState.get_player_position(world_id)
		if saved_position is Vector3:
			spawn_position = saved_position
	player.global_position = spawn_position
	player.velocity = Vector3.ZERO
	hud.set_world(world_id)
	if world_id == "seattle" and GameState.mark_seattle_arrival():
		hud.show_seattle_introduction.call_deferred()
	else:
		hud.show_toast("Arrived in %s." % world_id.capitalize(), 2.0)


func _on_interact_requested() -> void:
	if current_world == null or hud.is_modal_open() or travel_in_progress:
		return
	var target := current_world.get_closest_interactable(player.global_position)
	if target != null and target.has_method("interact"):
		gameplay_audio.play_interaction()
		target.interact(player)


func _on_ticket_requested(destination: String) -> void:
	hud.show_ticket(destination)


func _on_friend_conversation(friend_id: String, display_name: String) -> void:
	hud.show_friend_menu(friend_id, display_name)


func _begin_travel(destination: String) -> void:
	if travel_in_progress:
		return
	travel_in_progress = true
	player.control_enabled = false
	hud.set_prompt("")
	_save_current_position()
	GameState.save_game()
	gameplay_audio.start_travel()
	travel_cutscene.start_trip(GameState.current_world, destination)


func _on_travel_finished(destination: String) -> void:
	gameplay_audio.stop_travel()
	GameState.set_world(destination)
	_load_world(destination, true)
	GameState.set_player_position(destination, player.global_position)
	travel_in_progress = false
	player.control_enabled = not hud.is_modal_open()
	gameplay_audio.play_arrival()


func _on_party_invited() -> void:
	if current_world != null:
		current_world.refresh_friend_following()
	hud.show_toast("Kent and Joey will now follow you.")


func _on_friend_hello(friend_id: String) -> void:
	if current_world != null:
		current_world.wave_friend(friend_id)


func _on_all_friends_hello() -> void:
	if current_world != null:
		current_world.wave_all_friends()


func _on_player_step() -> void:
	gameplay_audio.play_footstep()


func _on_landmark_info(title: String, description: String) -> void:
	hud.show_landmark(title, description)


func _on_save_requested() -> void:
	_save_current_position()
	GameState.save_game()
	hud.show_toast("Progress saved on this Mac.")


func _on_quit_requested() -> void:
	_save_current_position()
	GameState.save_game()
	if current_world != null:
		current_world.stop_ambient_audio()
	gameplay_audio.shutdown()
	get_tree().quit()


func _on_ambient_audio_toggle() -> void:
	var enabled := not GameState.ambient_audio_enabled
	GameState.set_ambient_audio_enabled(enabled)
	if current_world != null:
		current_world.set_ambient_audio_enabled(enabled)
	gameplay_audio.set_enabled(enabled)
	hud.show_toast("Sound %s." % ("on" if enabled else "off"))


func _on_modal_changed(is_open: bool) -> void:
	if not travel_in_progress:
		player.control_enabled = not is_open


func _save_current_position() -> void:
	if current_world != null and not travel_in_progress:
		GameState.set_player_position(current_world.world_id, player.global_position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_current_position()
		if current_world != null:
			current_world.stop_ambient_audio()
		if gameplay_audio != null:
			gameplay_audio.shutdown()
		get_tree().quit()
