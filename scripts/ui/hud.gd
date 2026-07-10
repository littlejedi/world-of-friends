class_name GameHUD
extends CanvasLayer

signal travel_confirmed(destination: String)
signal party_invited
signal friend_hello_requested(friend_id: String)
signal all_friends_hello_requested
signal save_requested
signal quit_requested
signal ambient_audio_toggle_requested
signal modal_changed(is_open: bool)

var root: Control
var city_label: Label
var objective_label: Label
var collection_label: Label
var prompt_label: Label
var toast_label: Label
var modal: PanelContainer
var modal_content: VBoxContainer
var current_friend_id: String = ""
var current_friend_name: String = ""
var toast_serial: int = 0
var toast_timer: Timer
var current_world_id: String = "shanghai"


func _ready() -> void:
	layer = 10
	_build_interface()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_modal_open():
		close_modal()
		get_viewport().set_input_as_handled()


func _build_interface() -> void:
	root = Control.new()
	root.name = "Interface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", Color("#fff8e8"))
	for control_type in ["Button", "OptionButton"]:
		theme.set_color("font_color", control_type, Color("#f4f7f3"))
		theme.set_color("font_hover_color", control_type, Color("#fff0ae"))
		theme.set_color("font_pressed_color", control_type, Color("#ffffff"))
		theme.set_color("font_focus_color", control_type, Color("#fff0ae"))
		theme.set_stylebox("normal", control_type, _button_style(Color("#1c2a40"), Color("#60738a")))
		theme.set_stylebox("hover", control_type, _button_style(Color("#273b56"), Color("#e2b558")))
		theme.set_stylebox("pressed", control_type, _button_style(Color("#354d69"), Color("#f2ca72")))
		theme.set_stylebox("focus", control_type, _button_style(Color(0, 0, 0, 0), Color("#f2ca72")))
	root.theme = theme

	var info_panel := PanelContainer.new()
	info_panel.position = Vector2(12, 12)
	info_panel.size = Vector2(292, 82)
	info_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.07, 0.12, 0.88), Color("#e9b85d")))
	root.add_child(info_panel)
	var info_box := VBoxContainer.new()
	info_box.add_theme_constant_override("separation", 2)
	info_panel.add_child(info_box)
	city_label = Label.new()
	city_label.add_theme_font_size_override("font_size", 22)
	city_label.add_theme_color_override("font_color", Color("#ffe19a"))
	info_box.add_child(city_label)
	objective_label = Label.new()
	objective_label.add_theme_font_size_override("font_size", 13)
	objective_label.add_theme_color_override("font_color", Color("#d6e6e8"))
	info_box.add_child(objective_label)
	collection_label = Label.new()
	collection_label.add_theme_font_size_override("font_size", 12)
	collection_label.add_theme_color_override("font_color", Color("#9ed8cf"))
	info_box.add_child(collection_label)

	var controls := Label.new()
	controls.text = "WASD move  •  E interact  •  C cards\nG guide  •  M sound  •  scroll zoom"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	controls.anchor_left = 1.0
	controls.anchor_right = 1.0
	controls.offset_left = -310
	controls.offset_right = -12
	controls.offset_top = 16
	controls.offset_bottom = 54
	controls.add_theme_font_size_override("font_size", 11)
	controls.add_theme_color_override("font_color", Color("#e8eff0"))
	root.add_child(controls)

	prompt_label = Label.new()
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.anchor_top = 1.0
	prompt_label.anchor_bottom = 1.0
	prompt_label.offset_left = -210
	prompt_label.offset_right = 210
	prompt_label.offset_top = -48
	prompt_label.offset_bottom = -16
	prompt_label.add_theme_font_size_override("font_size", 17)
	prompt_label.add_theme_color_override("font_color", Color("#fff0ae"))
	root.add_child(prompt_label)

	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.anchor_left = 0.5
	toast_label.anchor_right = 0.5
	toast_label.offset_left = -240
	toast_label.offset_right = 240
	toast_label.offset_top = 88
	toast_label.offset_bottom = 120
	toast_label.add_theme_font_size_override("font_size", 16)
	toast_label.add_theme_color_override("font_color", Color("#fff4cf"))
	toast_label.visible = false
	root.add_child(toast_label)
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.timeout.connect(func() -> void: toast_label.visible = false)
	add_child(toast_timer)

	modal = PanelContainer.new()
	modal.name = "Modal"
	modal.anchor_left = 0.5
	modal.anchor_right = 0.5
	modal.anchor_top = 1.0
	modal.anchor_bottom = 1.0
	modal.offset_left = -235
	modal.offset_right = 235
	modal.offset_top = -330
	modal.offset_bottom = -18
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.065, 0.105, 0.97), Color("#f0bd5d")))
	modal.visible = false
	root.add_child(modal)
	modal_content = VBoxContainer.new()
	modal_content.add_theme_constant_override("separation", 7)
	modal.add_child(modal_content)


func _panel_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style


func _button_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func set_world(world_id: String) -> void:
	current_world_id = world_id
	city_label.text = "SHANGHAI" if world_id == "shanghai" else "SEATTLE"
	if world_id == "shanghai":
		objective_label.text = "Explore the city or visit the ticket office for Seattle."
	elif GameState.friends_in_party:
		objective_label.text = "Explore together or return to Shanghai."
	else:
		objective_label.text = "Meet Kent and Joey near the waterfront terminal."
	update_progress()


func update_collection_count() -> void:
	update_progress()


func update_progress() -> void:
	var discovered := GameState.get_discovery_count(current_world_id)
	var total := GameState.get_landmark_entries(current_world_id).size()
	collection_label.text = "CARDS  %d   •   GUIDE  %d/%d" % [GameState.player_cards.size(), discovered, total]


func set_prompt(prompt: String) -> void:
	prompt_label.text = "[E]  %s" % prompt if not prompt.is_empty() else ""


func is_modal_open() -> bool:
	return modal != null and modal.visible


func close_modal() -> void:
	if modal == null or not modal.visible:
		return
	modal.visible = false
	modal_changed.emit(false)


func show_ticket(destination: String) -> void:
	_clear_modal()
	_add_heading("INTERWORLD TICKET OFFICE")
	_add_body("Board the next shuttle to %s? Progress is saved before departure." % destination.capitalize())
	_add_button("Board shuttle", func() -> void:
		close_modal()
		travel_confirmed.emit(destination)
	)
	_add_button("Not yet", close_modal)
	_open_modal()


func show_friend_menu(friend_id: String, display_name: String) -> void:
	current_friend_id = friend_id
	current_friend_name = display_name
	_clear_modal()
	_add_heading(display_name.to_upper())
	var greeting := "%s adjusts his glasses and smiles." % display_name
	if GameState.friends_in_party:
		greeting = "%s is traveling with you." % display_name
	_add_body(greeting)
	_add_button("Say hello", _show_hello)
	if not GameState.friends_in_party:
		_add_button("Ask Kent and Joey to travel together", _invite_friends)
	_add_button("Trade cards", _trade_card)
	_add_button("Goodbye", close_modal)
	_open_modal()


func show_seattle_introduction() -> void:
	_clear_modal()
	_add_heading("WELCOME TO SEATTLE")
	_add_body("Two friends are waiting near the waterfront terminal.\n\nKent: “Hello! You made it.”\nJoey: “Come explore Seattle with us!”")
	_add_button("Say hello", func() -> void:
		all_friends_hello_requested.emit()
		show_toast("Kent and Joey wave hello.")
		close_modal()
	)
	_open_modal()


func _show_hello() -> void:
	friend_hello_requested.emit(current_friend_id)
	_clear_modal()
	_add_heading(current_friend_name.to_upper())
	_add_body("You say hello. %s waves back enthusiastically." % current_friend_name)
	_add_button("Continue", func() -> void: show_friend_menu(current_friend_id, current_friend_name))


func _invite_friends() -> void:
	GameState.invite_friends()
	party_invited.emit()
	_clear_modal()
	_add_heading("TRAVEL TOGETHER")
	_add_body("Kent and Joey joined your party. They will explore and ride the shuttle with you.")
	_add_button("Great!", close_modal)
	set_world(GameState.current_world)


func _trade_card() -> void:
	_clear_modal()
	_add_heading("CARD TRADE")
	_add_body("Choose one card from each collection.")
	var player_picker := _add_card_picker("Your card", GameState.player_cards)
	var available: Array = GameState.friend_cards.get(current_friend_id, [])
	var friend_picker := _add_card_picker("%s's card" % current_friend_name, available)
	_add_button("Confirm trade", func() -> void:
		_confirm_trade(player_picker.selected, friend_picker.selected)
	)
	_add_button("Back", func() -> void: show_friend_menu(current_friend_id, current_friend_name))


func _confirm_trade(player_index: int, friend_index: int) -> void:
	var result := GameState.trade_cards(current_friend_id, player_index, friend_index)
	_clear_modal()
	_add_heading("TRADE COMPLETE" if bool(result.ok) else "TRADE UNAVAILABLE")
	_add_body(str(result.message))
	var collection_names: Array[String] = []
	for card in GameState.player_cards:
		collection_names.append(str(card.name))
	update_collection_count()
	_add_body("Your cards: %s" % ", ".join(collection_names))
	_add_button("Back", func() -> void: show_friend_menu(current_friend_id, current_friend_name))


func _add_card_picker(title: String, cards: Array) -> OptionButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label := Label.new()
	label.text = title
	label.custom_minimum_size.x = 112
	label.add_theme_color_override("font_color", Color("#d9e8ea"))
	row.add_child(label)
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.custom_minimum_size.y = 30
	for index in range(cards.size()):
		var card: Dictionary = cards[index]
		picker.add_item("%s  ·  %s" % [card.name, card.rarity], index)
		var texture := GameState.get_card_texture(str(card.id))
		if texture != null:
			picker.set_item_icon(index, texture)
	if cards.is_empty():
		picker.add_item("No cards available")
		picker.disabled = true
	row.add_child(picker)
	modal_content.add_child(row)
	return picker


func show_landmark(title: String, description: String, is_new: bool = false) -> void:
	_clear_modal()
	if is_new:
		_add_kicker("NEW LANDMARK DISCOVERED")
	_add_heading(title.to_upper())
	_add_body(description)
	update_progress()
	_add_button("Continue exploring", close_modal)
	_open_modal()


func show_city_guide() -> void:
	_clear_modal()
	_add_heading("CITY GUIDE  •  %s" % current_world_id.to_upper())
	var entries := GameState.get_landmark_entries(current_world_id)
	_add_body("Landmarks discovered: %d of %d" % [GameState.get_discovery_count(current_world_id), entries.size()])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for entry in entries:
		grid.add_child(_make_guide_tile(entry, GameState.is_landmark_discovered(str(entry.id))))
	modal_content.add_child(grid)
	_add_button("Close guide", close_modal)
	_open_modal()


func _make_guide_tile(entry: Dictionary, discovered: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "Guide_%s" % str(entry.id)
	panel.custom_minimum_size = Vector2(202, 66)
	var border := Color("#d7ae5f") if discovered else Color("#56687a")
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#172438"), border))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	panel.add_child(box)
	var status := Label.new()
	status.text = "[x]  DISCOVERED" if discovered else "[ ]  NOT YET VISITED"
	status.add_theme_font_size_override("font_size", 10)
	status.add_theme_color_override("font_color", Color("#f2c96d") if discovered else Color("#91a4b1"))
	box.add_child(status)
	var title := Label.new()
	title.text = str(entry.title)
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("#fff0c0"))
	box.add_child(title)
	var hint := Label.new()
	hint.text = str(entry.hint)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 9)
	hint.add_theme_color_override("font_color", Color("#b8cbd0"))
	box.add_child(hint)
	return panel


func show_collection() -> void:
	_clear_modal()
	_add_heading("YOUR CARD COLLECTION")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for card in GameState.player_cards:
		grid.add_child(_make_card_tile(card))
	modal_content.add_child(grid)
	_add_button("Close collection", close_modal)
	_open_modal()


func _make_card_tile(card: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(132, 92)
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#172438"), Color("#526b80")))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	panel.add_child(box)
	var texture := GameState.get_card_texture(str(card.id))
	if texture != null:
		var image := TextureRect.new()
		image.texture = texture
		image.custom_minimum_size = Vector2(24, 30)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(image)
	var name_label := Label.new()
	name_label.text = str(card.name)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("#fff0c0"))
	box.add_child(name_label)
	var rarity_label := Label.new()
	rarity_label.text = str(card.rarity)
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 11)
	rarity_label.add_theme_color_override("font_color", Color("#9ed8cf"))
	box.add_child(rarity_label)
	return panel


func show_pause_menu() -> void:
	_clear_modal()
	_add_heading("PAUSED")
	_add_body("Progress is saved locally on this device.")
	_add_button("Resume", close_modal)
	_add_button("View card collection", show_collection)
	_add_button("Open city guide", show_city_guide)
	_add_button("Sound: %s" % ("On" if GameState.ambient_audio_enabled else "Off"), func() -> void:
		ambient_audio_toggle_requested.emit()
		show_pause_menu()
	)
	_add_button("Save now", func() -> void:
		close_modal()
		save_requested.emit()
	)
	_add_button("Quit game", func() -> void: quit_requested.emit())
	_open_modal()


func _clear_modal() -> void:
	for child in modal_content.get_children():
		child.queue_free()


func _add_heading(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", Color("#ffdf8d"))
	modal_content.add_child(label)


func _add_kicker(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("#f2c96d"))
	modal_content.add_child(label)


func _add_body(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(420, 0)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("#edf4f2"))
	modal_content.add_child(label)


func _add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 28
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	modal_content.add_child(button)


func _open_modal() -> void:
	modal.visible = true
	modal_changed.emit(true)
	var buttons := modal_content.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		buttons[0].grab_focus()


func show_toast(message: String, duration: float = 3.0) -> void:
	toast_serial += 1
	toast_label.text = message
	toast_label.visible = true
	toast_timer.start(duration)
