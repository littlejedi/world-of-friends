class_name WorldScene
extends Node3D

signal travel_requested(destination: String)
signal friend_conversation_requested(friend_id: String, display_name: String)
signal landmark_info_requested(landmark_id: String, title: String, description: String)

const Art = preload("res://scripts/art/procedural_factory.gd")
const TicketOfficeScript = preload("res://scripts/gameplay/ticket_office.gd")
const FriendScript = preload("res://scripts/gameplay/friend_npc.gd")
const LandmarkScript = preload("res://scripts/gameplay/landmark_interactable.gd")
const WaterScript = preload("res://scripts/art/water_surface.gd")
const AmbientMoverScript = preload("res://scripts/art/ambient_mover.gd")
const RotationAnimatorScript = preload("res://scripts/art/rotation_animator.gd")
const AmbientAudioScript = preload("res://scripts/art/ambient_audio.gd")

var world_id: String = "shanghai"
var player: Node3D
var friends: Array[FriendNPC] = []
var companion_trail: Array[Vector3] = []
var ambient_audio: AmbientAudio


func build(new_world_id: String, player_node: Node3D) -> void:
	world_id = new_world_id
	player = player_node
	_build_environment()
	if world_id == "shanghai":
		_build_shanghai()
	else:
		_build_seattle()
	_build_friends()


func get_spawn_position(arriving: bool = false) -> Vector3:
	if world_id == "shanghai":
		return Vector3(5.8, 0.08, 4.3) if arriving else Vector3(-5.8, 0.08, -5.2)
	return Vector3(8.2, 0.08, 3.8) if arriving else Vector3(-6.0, 0.08, -5.0)


func get_closest_interactable(from_position: Vector3, max_distance: float = 3.25) -> Node3D:
	var closest: Node3D
	var closest_distance := max_distance
	for candidate in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(candidate) or not is_ancestor_of(candidate):
			continue
		var distance := from_position.distance_to(candidate.global_position)
		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	return closest


func get_surface_type(at_position: Vector3) -> String:
	if at_position.z >= 8.0:
		return "promenade" if world_id == "shanghai" else "pier"
	if absf(at_position.z + 3.5) <= 2.15 or absf(at_position.x - 2.5) <= 2.15:
		return "road"
	return "ground"


func refresh_friend_following() -> void:
	companion_trail.clear()
	if GameState.friends_in_party and player != null:
		companion_trail.append(player.global_position)
	for friend in friends:
		friend.set_follow_target(player if GameState.friends_in_party else null)


func update_companion_trail(player_position: Vector3) -> void:
	if not GameState.friends_in_party or friends.is_empty():
		return
	if companion_trail.is_empty():
		companion_trail.append(player_position)
	if companion_trail.back().distance_to(player_position) >= 0.38:
		companion_trail.append(player_position)
		if companion_trail.size() > 90:
			companion_trail.pop_front()
	for index in range(friends.size()):
		var steps_back := 8 + index * 6
		var trail_index := maxi(0, companion_trail.size() - 1 - steps_back)
		var point := companion_trail[trail_index]
		var path_direction := Vector3(0, 0, -1)
		if trail_index < companion_trail.size() - 1:
			path_direction = companion_trail[trail_index + 1] - point
			path_direction.y = 0.0
			if path_direction.length_squared() > 0.001:
				path_direction = path_direction.normalized()
		var side := Vector3(-path_direction.z, 0, path_direction.x)
		var side_amount := -0.38 if index == 0 else 0.38
		friends[index].set_follow_point(point + side * side_amount)


func wave_friend(friend_id: String) -> void:
	for friend in friends:
		if friend.friend_id == friend_id:
			friend.wave()
			return


func wave_all_friends() -> void:
	for friend in friends:
		friend.wave()


func set_ambient_audio_enabled(enabled: bool) -> void:
	if ambient_audio != null:
		ambient_audio.set_enabled(enabled)


func stop_ambient_audio() -> void:
	if ambient_audio != null:
		ambient_audio.shutdown()


func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	if world_id == "shanghai":
		environment.background_color = Color("#9bc3c9")
		environment.ambient_light_color = Color("#ffe0b8")
	else:
		environment.background_color = Color("#89a9b6")
		environment.ambient_light_color = Color("#c7dbe0")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_energy = 0.38
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-58, -34, 0)
	sun.light_color = Color("#ffe6bd") if world_id == "shanghai" else Color("#e4f1f2")
	sun.light_energy = 0.68
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 45.0
	add_child(sun)
	ambient_audio = AmbientAudioScript.new()
	ambient_audio.setup(world_id, GameState.ambient_audio_enabled)
	add_child(ambient_audio)


func _build_ground(base_color: Color) -> void:
	Art.add_static_box(self, "Ground", Vector3(0, -0.23, 0), Vector3(48, 0.46, 36), base_color, false)
	Art.add_box(self, "RoadA", Vector3(0, 0.015, -3.5), Vector3(48, 0.04, 4.2), Color("#43505a"), false)
	Art.add_box(self, "RoadB", Vector3(2.5, 0.02, -4.0), Vector3(4.2, 0.05, 28), Color("#46535e"), false)
	for x in range(-22, 23, 3):
		Art.add_box(self, "RoadMark", Vector3(x, 0.045, -3.5), Vector3(1.3, 0.03, 0.10), Color("#e8dca2"), false)
	# Invisible edge blocks keep the player inside the postcard world without
	# introducing tall walls into the fixed-camera composition.
	Art.add_collision_box(self, "NorthEdge", Vector3(0, 0.75, -18.0), Vector3(48, 1.5, 0.6))
	Art.add_collision_box(self, "WestEdge", Vector3(-24.0, 0.75, 0), Vector3(0.6, 1.5, 36))
	Art.add_collision_box(self, "EastEdge", Vector3(24.0, 0.75, 0), Vector3(0.6, 1.5, 36))


func _build_shanghai() -> void:
	_build_ground(Color("#c9b991"))
	Art.add_label(self, "SHANGHAI", Vector3(-20, 6.5, -15.5), 56, Color("#fff0c2"))
	_build_wukang_mansion(Vector3(-11.5, 0, -9.0))
	_build_oriental_pearl(Vector3(15.0, 0, -10.2))
	_build_shanghai_riverside()
	var office: TicketOffice = TicketOfficeScript.new()
	office.setup("Shanghai", "seattle")
	office.position = Vector3(8.4, 0, 5.6)
	office.travel_requested.connect(_on_ticket_requested)
	add_child(office)
	for tree_position in [Vector3(-18, 0, -2), Vector3(-15, 0, -1), Vector3(-8, 0, -1), Vector3(-5, 0, -7), Vector3(-4, 0, 3), Vector3(-10, 0, 5), Vector3(17, 0, 2)]:
		Art.add_tree(self, tree_position, 1.0)
	_add_landmark("wukang_mansion", "Wukang Mansion", "A stylized version of Shanghai's distinctive flatiron-shaped apartment building, framed by the leafy streets of Xuhui.", Vector3(-6.3, 0, -6.7))
	_add_landmark("oriental_pearl", "Oriental Pearl Tower", "The glowing spheres of this skyline landmark mark the Pudong side of the Huangpu River.", Vector3(12.4, 0, -8.2))
	_add_landmark("xuhui_riverside", "Xuhui Riverside", "A broad riverside promenade for walking, resting, and looking across Shanghai's changing waterfront.", Vector3(-4.0, 0, 9.1))
	_add_ambient_boat("HuangpuRiverBoat", Vector3(-20, 0.18, 14.4), Vector3(20, 0.18, 14.4), Color("#d47a4d"), 18.0)
	_add_bird_flock("ShanghaiBirds", Vector3(-18, 7.2, 1.0), Vector3(20, 7.2, 1.0), 22.0)
	_add_street_walker("ShanghaiWalkerA", Vector3(-18, 0.02, -0.8), Vector3(-7, 0.02, -0.8), Color("#4f7eb8"), 0.88, 13.0)
	_add_street_walker("ShanghaiWalkerB", Vector3(-12, 0.02, 4.0), Vector3(-2, 0.02, 4.0), Color("#b85f59"), 0.84, 15.0)


func _build_wukang_mansion(origin: Vector3) -> void:
	var building := Node3D.new()
	building.name = "WukangMansion"
	building.position = origin
	add_child(building)
	Art.add_static_box(building, "MainWing", Vector3(0, 2.45, 0.8), Vector3(10.0, 4.9, 4.0), Color("#a95243"))
	Art.add_triangular_prism(building, "FlatironNose", Vector3(5.1, 3.0, 0.8), Vector3(4.2, 6.0, 4.0), Color("#b65c49"))
	Art.add_collision_box(building, "NoseCollision", Vector3(4.6, 3.0, 0.8), Vector3(3.2, 6.0, 2.8))
	Art.add_box(building, "Roof", Vector3(0.8, 5.05, 0.55), Vector3(11.2, 0.35, 4.4), Color("#3c4147"))
	Art.add_triangular_prism(building, "NoseRoof", Vector3(5.1, 6.1, 0.8), Vector3(4.5, 0.28, 4.3), Color("#343b42"))
	for floor_index in range(3):
		for window_index in range(7):
			Art.add_box(building, "Window", Vector3(-3.9 + window_index * 1.25, 1.25 + floor_index * 1.25, -1.22), Vector3(0.52, 0.7, 0.08), Color("#9ed1d0"), false)
			Art.add_box(building, "WindowCameraSide", Vector3(-3.9 + window_index * 1.25, 1.25 + floor_index * 1.25, 2.82), Vector3(0.52, 0.7, 0.08), Color("#9ed1d0"), false)
		Art.add_box(building, "NoseWindow", Vector3(7.23, 1.25 + floor_index * 1.25, 0.8), Vector3(0.08, 0.7, 0.52), Color("#b8ddda"), false)
	Art.add_box(building, "CornerCanopy", Vector3(7.25, 0.72, 0.8), Vector3(0.55, 0.15, 1.4), Color("#374b45"), false)
	Art.add_label(building, "WUKANG MANSION", Vector3(0, 6.2, 0), 34, Color("#ffe6b3"))


func _build_oriental_pearl(origin: Vector3) -> void:
	var tower := Node3D.new()
	tower.name = "OrientalPearlTower"
	tower.position = origin
	add_child(tower)
	Art.add_cylinder(tower, "Podium", Vector3(0, 0.28, 0), 1.65, 0.55, Color("#d5d9d7"), 12)
	for support_index in range(3):
		var support_angle := TAU * float(support_index) / 3.0
		var support_start := Vector3(cos(support_angle) * 1.45, 0.5, sin(support_angle) * 1.45)
		var support_end := Vector3(cos(support_angle) * 0.45, 3.1, sin(support_angle) * 0.45)
		Art.add_beam(tower, "Support%d" % support_index, support_start, support_end, 0.24, Color("#e4e6e3"))
	Art.add_cylinder(tower, "Stem", Vector3(0, 5.0, 0), 0.28, 10.0, Color("#e6e9e9"), 10)
	Art.add_sphere(tower, "LowerPearl", Vector3(0, 3.25, 0), 1.55, Color("#c94f72"), 14, 7)
	Art.add_cylinder(tower, "LowerDeck", Vector3(0, 3.25, 0), 1.72, 0.18, Color("#f0d9df"), 16)
	Art.add_sphere(tower, "UpperPearl", Vector3(0, 7.8, 0), 1.05, Color("#d85f80"), 14, 7)
	Art.add_cylinder(tower, "UpperDeck", Vector3(0, 7.8, 0), 1.22, 0.16, Color("#f2dce3"), 16)
	Art.add_cylinder(tower, "Spire", Vector3(0, 10.2, 0), 0.11, 4.1, Color("#f0ece7"), 8)
	Art.add_sphere(tower, "Beacon", Vector3(0, 10.55, 0), 0.28, Color("#e76b8e"), 10, 5)
	Art.add_static_box(tower, "BaseCollision", Vector3(0, 1.0, 0), Vector3(2.7, 2.0, 2.7), Color("#e1dfd4"), false)
	Art.add_label(tower, "ORIENTAL PEARL", Vector3(0, 12.7, 0), 32, Color("#ffe0ec"))


func _build_shanghai_riverside() -> void:
	var water := WaterScript.new()
	water.name = "HuangpuRiver"
	water.position = Vector3(0, -0.05, 14.6)
	water.setup(Vector2(48, 6.4), Color("#397c94"), Color("#8fd2d1"))
	add_child(water)
	Art.add_static_box(self, "RiversideRail", Vector3(0, 0.45, 11.6), Vector3(48, 0.9, 0.28), Color("#7b8991"), false)
	Art.add_box(self, "Promenade", Vector3(0, 0.01, 9.8), Vector3(48, 0.05, 3.2), Color("#d7cbb0"), false)
	Art.add_label(self, "XUHUI RIVERSIDE", Vector3(-8, 2.8, 10.3), 34, Color("#fff0cf"))


func _build_seattle() -> void:
	_build_ground(Color("#9baaa1"))
	Art.add_label(self, "SEATTLE", Vector3(-20, 6.5, -15.5), 56, Color("#eaf7f2"))
	_build_pike_place(Vector3(-12.0, 0, -8.5))
	_build_space_needle(Vector3(13.2, 0, -9.5))
	_build_seattle_waterfront()
	var office: TicketOffice = TicketOfficeScript.new()
	office.setup("Seattle", "shanghai")
	office.position = Vector3(9.0, 0, 5.3)
	office.travel_requested.connect(_on_ticket_requested)
	add_child(office)
	for tree_position in [Vector3(-18, 0, -1), Vector3(-15, 0, 2), Vector3(-5, 0, -8), Vector3(5, 0, -9), Vector3(18, 0, -1), Vector3(15, 0, 3)]:
		Art.add_tree(self, tree_position, 1.08)
	_add_landmark("pike_place", "Pike Place Market", "A compact market district filled with produce stands, flowers, warm signs, and steep streets leading toward the water.", Vector3(-6.6, 0, -6.3))
	_add_landmark("space_needle", "Space Needle", "Seattle's space-age observation tower rises above the northern side of this postcard world.", Vector3(10.7, 0, -7.4))
	_add_landmark("seattle_aquarium", "Seattle Aquarium", "A waterfront aquarium on Pier 59, represented here by its glassy marine-blue facade.", Vector3(-5.4, 0, 3.8))
	_add_landmark("great_wheel", "Seattle Great Wheel", "A glowing waterfront wheel overlooking Elliott Bay and the distant sea.", Vector3(3.4, 0, 8.7))
	_add_ambient_boat("ElliottBayFerry", Vector3(-21, 0.22, 14.8), Vector3(21, 0.22, 14.8), Color("#e8eee8"), 20.0)
	_add_bird_flock("SeattleGulls", Vector3(20, 7.6, 2.0), Vector3(-20, 7.6, 2.0), 19.0)
	_add_street_walker("SeattleWalkerA", Vector3(-18, 0.02, -1.0), Vector3(-7, 0.02, -1.0), Color("#d28b45"), 0.90, 14.0)
	_add_street_walker("SeattleWalkerB", Vector3(-5, 0.02, 8.4), Vector3(6, 0.02, 8.4), Color("#5a8b75"), 0.86, 16.0)


func _build_pike_place(origin: Vector3) -> void:
	var market := Node3D.new()
	market.name = "PikePlaceMarket"
	market.position = origin
	add_child(market)
	Art.add_static_box(market, "MarketBuilding", Vector3(0, 2.2, 0.8), Vector3(9.0, 4.4, 4.0), Color("#d3c1a1"))
	Art.add_box(market, "Awning", Vector3(0, 1.65, -1.45), Vector3(8.6, 0.18, 1.15), Color("#38765c"))
	Art.add_box(market, "SignPanel", Vector3(0, 4.2, -1.25), Vector3(7.5, 1.0, 0.18), Color("#ad2f36"), false)
	Art.add_box(market, "SignPanelCameraSide", Vector3(0, 4.2, 2.85), Vector3(7.5, 1.0, 0.18), Color("#ad2f36"), false)
	Art.add_label(market, "PIKE PLACE MARKET", Vector3(0, 4.25, -1.4), 34, Color("#fff2d0"))
	Art.add_label(market, "PIKE PLACE MARKET", Vector3(0, 4.25, 3.0), 34, Color("#fff2d0"))
	var market_clock := Art.add_cylinder(market, "MarketClock", Vector3(3.65, 4.2, -1.38), 0.46, 0.10, Color("#f2e8ce"), 16)
	market_clock.rotation_degrees.x = 90
	Art.add_box(market, "ClockHandHour", Vector3(3.65, 4.28, -1.45), Vector3(0.07, 0.30, 0.04), Color("#29313b"), false).rotation_degrees.z = 32
	Art.add_box(market, "ClockHandMinute", Vector3(3.76, 4.15, -1.46), Vector3(0.07, 0.38, 0.04), Color("#29313b"), false).rotation_degrees.z = -58
	for stall_x in [-3.1, -1.0, 1.1, 3.2]:
		Art.add_box(market, "MarketStall", Vector3(stall_x, 0.65, -1.9), Vector3(1.5, 1.25, 0.8), Color("#d97854"))
		Art.add_box(market, "FlowerCrate", Vector3(stall_x, 1.38, -2.0), Vector3(1.15, 0.22, 0.64), Color("#e6b85d"), false)


func _build_space_needle(origin: Vector3) -> void:
	var needle := Node3D.new()
	needle.name = "SpaceNeedle"
	needle.position = origin
	add_child(needle)
	for leg_index in range(3):
		var leg_angle := TAU * float(leg_index) / 3.0
		var leg_start := Vector3(cos(leg_angle) * 1.75, 0.25, sin(leg_angle) * 1.75)
		var leg_end := Vector3(cos(leg_angle) * 0.34, 6.45, sin(leg_angle) * 0.34)
		Art.add_beam(needle, "Leg%d" % leg_index, leg_start, leg_end, 0.28, Color("#d9dedb"))
	Art.add_cylinder(needle, "Column", Vector3(0, 4.4, 0), 0.30, 8.8, Color("#d9dedb"), 10)
	Art.add_cylinder(needle, "ObservationDeck", Vector3(0, 8.2, 0), 1.92, 0.34, Color("#d2d5c8"), 16)
	Art.add_cylinder(needle, "DeckGlass", Vector3(0, 8.46, 0), 1.55, 0.30, Color("#71a9ad"), 16)
	Art.add_cylinder(needle, "Restaurant", Vector3(0, 8.65, 0), 1.25, 0.4, Color("#d47955"), 14)
	Art.add_cylinder(needle, "SaucerRoof", Vector3(0, 8.9, 0), 1.72, 0.16, Color("#e4e5dd"), 16)
	Art.add_cylinder(needle, "Spire", Vector3(0, 10.2, 0), 0.10, 3.1, Color("#eef1ec"), 8)
	Art.add_static_box(needle, "BaseCollision", Vector3(0, 0.8, 0), Vector3(2.6, 1.6, 2.6), Color("#bbc4bd"), false)
	Art.add_label(needle, "SPACE NEEDLE", Vector3(0, 12.1, 0), 32, Color("#effff7"))


func _build_seattle_waterfront() -> void:
	var water := WaterScript.new()
	water.name = "ElliottBay"
	water.position = Vector3(0, -0.05, 14.6)
	water.setup(Vector2(48, 6.4), Color("#326d86"), Color("#84c8d4"))
	add_child(water)
	Art.add_static_box(self, "WaterfrontRail", Vector3(0, 0.45, 11.6), Vector3(48, 0.9, 0.28), Color("#61727b"), false)
	Art.add_box(self, "WaterfrontWalk", Vector3(0, 0.01, 9.8), Vector3(48, 0.05, 3.2), Color("#bfc1b6"), false)
	var aquarium := Node3D.new()
	aquarium.name = "SeattleAquarium"
	aquarium.position = Vector3(-8.5, 0, 5.8)
	add_child(aquarium)
	Art.add_static_box(aquarium, "Building", Vector3(0, 1.45, 0.8), Vector3(6.0, 2.9, 3.2), Color("#497d82"))
	Art.add_box(aquarium, "Glass", Vector3(0, 1.5, -0.84), Vector3(4.6, 1.35, 0.08), Color("#70bdc8"), false)
	Art.add_box(aquarium, "GlassCameraSide", Vector3(0, 1.5, 2.42), Vector3(4.6, 1.35, 0.08), Color("#70bdc8"), false)
	Art.add_label(aquarium, "SEATTLE AQUARIUM", Vector3(0, 3.65, 0), 30, Color("#e6ffff"))
	_build_great_wheel(Vector3(1.5, 0, 7.8))
	Art.add_label(self, "ELLIOTT BAY", Vector3(-2, 2.2, 12.8), 32, Color("#dff9ff"))


func _build_great_wheel(origin: Vector3) -> void:
	var wheel := Node3D.new()
	wheel.name = "SeattleGreatWheel"
	wheel.position = origin
	add_child(wheel)
	var rotor := RotationAnimatorScript.new()
	rotor.name = "WheelRotor"
	rotor.position.y = 3.5
	rotor.setup(0.075)
	wheel.add_child(rotor)
	var radius := 3.0
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		var segment := Art.add_box(rotor, "Rim", Vector3(cos(angle) * radius, sin(angle) * radius, 0), Vector3(0.20, 1.25, 0.28), Color("#e9e4d7"))
		segment.rotation_degrees.z = -rad_to_deg(angle)
		if index % 2 == 0:
			Art.add_box(rotor, "Cabin", Vector3(cos(angle) * radius, sin(angle) * radius, 0), Vector3(0.55, 0.55, 0.65), Color("#c84f52"))
		var spoke := Art.add_box(rotor, "Spoke", Vector3(cos(angle) * radius * 0.5, sin(angle) * radius * 0.5, 0), Vector3(0.07, radius, 0.07), Color("#d6d4ca"), false)
		spoke.rotation_degrees.z = -rad_to_deg(angle)
	Art.add_cylinder(rotor, "Axle", Vector3.ZERO, 0.33, 1.0, Color("#bf554f"), 10).rotation_degrees.x = 90
	Art.add_static_box(wheel, "Base", Vector3(0, 0.5, 0), Vector3(4.0, 1.0, 1.5), Color("#6d6f70"), false)
	Art.add_label(wheel, "GREAT WHEEL", Vector3(0, 7.5, 0), 28, Color("#fff5df"))


func _build_friends() -> void:
	if world_id != "seattle" and not GameState.friends_in_party:
		return
	var base_position := Vector3(5.8, 0.08, 3.3) if world_id == "seattle" else Vector3(4.0, 0.08, 4.0)
	var kent: FriendNPC = FriendScript.new()
	kent.setup("kent", "Kent", 0.98, Color("#4678b7"), Vector3(-1.15, 0, 1.15))
	kent.position = base_position + Vector3(-1.0, 0, 0)
	kent.conversation_requested.connect(_on_friend_conversation)
	add_child(kent)
	friends.append(kent)
	var joey: FriendNPC = FriendScript.new()
	joey.setup("joey", "Joey", 0.90, Color("#c66655"), Vector3(1.15, 0, 1.15))
	joey.position = base_position + Vector3(1.0, 0, 0)
	joey.conversation_requested.connect(_on_friend_conversation)
	add_child(joey)
	friends.append(joey)
	refresh_friend_following()


func _add_landmark(landmark_id: String, title: String, description: String, location: Vector3) -> void:
	var landmark := LandmarkScript.new()
	landmark.setup(landmark_id, title, description)
	landmark.position = location
	landmark.info_requested.connect(_on_landmark_info)
	add_child(landmark)


func _add_ambient_boat(
	boat_name: String,
	start: Vector3,
	end: Vector3,
	accent: Color,
	duration: float
) -> void:
	var boat := AmbientMoverScript.new()
	boat.name = boat_name
	boat.setup(start, end, duration, 0.035)
	add_child(boat)
	Art.add_box(boat, "Hull", Vector3(0, 0.24, 0), Vector3(3.4, 0.42, 1.1), Color("#30485a"), false)
	Art.add_box(boat, "Deck", Vector3(0, 0.58, 0), Vector3(2.4, 0.48, 0.9), accent, false)
	Art.add_box(boat, "Cabin", Vector3(0.25, 0.96, 0), Vector3(1.3, 0.42, 0.72), Color("#d8f0ed"), false)
	Art.add_box(boat, "Window", Vector3(0.25, 1.0, -0.38), Vector3(0.72, 0.18, 0.04), Color("#66b6cb"), false)


func _add_bird_flock(flock_name: String, start: Vector3, end: Vector3, duration: float) -> void:
	var flock := AmbientMoverScript.new()
	flock.name = flock_name
	flock.setup(start, end, duration, 0.18)
	add_child(flock)
	for offset in [Vector3.ZERO, Vector3(-0.8, -0.25, 0.3), Vector3(-1.5, 0.2, -0.2)]:
		var bird := Node3D.new()
		bird.position = offset
		flock.add_child(bird)
		var left_wing := Art.add_box(bird, "WingL", Vector3(-0.16, 0, 0), Vector3(0.34, 0.05, 0.12), Color("#354052"), false)
		left_wing.rotation_degrees.z = -18
		var right_wing := Art.add_box(bird, "WingR", Vector3(0.16, 0, 0), Vector3(0.34, 0.05, 0.12), Color("#354052"), false)
		right_wing.rotation_degrees.z = 18


func _add_street_walker(
	walker_name: String,
	start: Vector3,
	end: Vector3,
	shirt_color: Color,
	height_scale: float,
	duration: float
) -> void:
	var walker := AmbientMoverScript.new()
	walker.name = walker_name
	walker.setup(start, end, duration, 0.025)
	add_child(walker)
	Art.add_character_visual(
		walker,
		height_scale,
		shirt_color,
		Color("#3d4c62"),
		Color("#dca77c"),
		Color("#3a3035"),
		false
	)


func _on_ticket_requested(destination: String) -> void:
	travel_requested.emit(destination)


func _on_friend_conversation(friend_id: String, display_name: String) -> void:
	friend_conversation_requested.emit(friend_id, display_name)


func _on_landmark_info(landmark_id: String, title: String, description: String) -> void:
	landmark_info_requested.emit(landmark_id, title, description)
