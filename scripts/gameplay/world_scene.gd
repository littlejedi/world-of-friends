class_name WorldScene
extends Node3D

signal travel_requested(destination: String)
signal friend_conversation_requested(friend_id: String, display_name: String)

const Art = preload("res://scripts/art/procedural_factory.gd")
const TicketOfficeScript = preload("res://scripts/gameplay/ticket_office.gd")
const FriendScript = preload("res://scripts/gameplay/friend_npc.gd")

var world_id: String = "shanghai"
var player: Node3D
var friends: Array[FriendNPC] = []


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


func refresh_friend_following() -> void:
	for friend in friends:
		friend.set_follow_target(player if GameState.friends_in_party else null)


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


func _build_wukang_mansion(origin: Vector3) -> void:
	var building := Node3D.new()
	building.name = "WukangMansion"
	building.position = origin
	add_child(building)
	Art.add_static_box(building, "MainWing", Vector3(0, 2.45, 0.8), Vector3(10.0, 4.9, 4.0), Color("#a95243"))
	Art.add_static_box(building, "CornerWing", Vector3(4.6, 3.0, -0.3), Vector3(2.4, 6.0, 2.8), Color("#b65c49"))
	Art.add_box(building, "Roof", Vector3(0.8, 5.05, 0.55), Vector3(11.2, 0.35, 4.4), Color("#3c4147"))
	for floor_index in range(3):
		for window_index in range(7):
			Art.add_box(building, "Window", Vector3(-3.9 + window_index * 1.25, 1.25 + floor_index * 1.25, -1.22), Vector3(0.52, 0.7, 0.08), Color("#9ed1d0"), false)
			Art.add_box(building, "WindowCameraSide", Vector3(-3.9 + window_index * 1.25, 1.25 + floor_index * 1.25, 2.82), Vector3(0.52, 0.7, 0.08), Color("#9ed1d0"), false)
	Art.add_label(building, "WUKANG MANSION", Vector3(0, 6.2, 0), 34, Color("#ffe6b3"))


func _build_oriental_pearl(origin: Vector3) -> void:
	var tower := Node3D.new()
	tower.name = "OrientalPearlTower"
	tower.position = origin
	add_child(tower)
	Art.add_cylinder(tower, "Stem", Vector3(0, 5.0, 0), 0.28, 10.0, Color("#e6e9e9"), 10)
	Art.add_sphere(tower, "LowerPearl", Vector3(0, 3.25, 0), 1.55, Color("#c94f72"), 14, 7)
	Art.add_sphere(tower, "UpperPearl", Vector3(0, 7.8, 0), 1.05, Color("#d85f80"), 14, 7)
	Art.add_cylinder(tower, "Spire", Vector3(0, 10.2, 0), 0.11, 4.1, Color("#f0ece7"), 8)
	Art.add_static_box(tower, "BaseCollision", Vector3(0, 1.0, 0), Vector3(2.7, 2.0, 2.7), Color("#e1dfd4"), false)
	Art.add_label(tower, "ORIENTAL PEARL", Vector3(0, 12.7, 0), 32, Color("#ffe0ec"))


func _build_shanghai_riverside() -> void:
	Art.add_box(self, "HuangpuRiver", Vector3(0, -0.05, 14.6), Vector3(48, 0.18, 6.4), Color("#4d8fa4"), false)
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
	for stall_x in [-3.1, -1.0, 1.1, 3.2]:
		Art.add_box(market, "MarketStall", Vector3(stall_x, 0.65, -1.9), Vector3(1.5, 1.25, 0.8), Color("#d97854"))


func _build_space_needle(origin: Vector3) -> void:
	var needle := Node3D.new()
	needle.name = "SpaceNeedle"
	needle.position = origin
	add_child(needle)
	Art.add_cylinder(needle, "Column", Vector3(0, 4.4, 0), 0.30, 8.8, Color("#d9dedb"), 10)
	Art.add_cylinder(needle, "ObservationDeck", Vector3(0, 8.2, 0), 1.75, 0.65, Color("#d2d5c8"), 14)
	Art.add_cylinder(needle, "Restaurant", Vector3(0, 8.65, 0), 1.25, 0.4, Color("#d47955"), 14)
	Art.add_cylinder(needle, "Spire", Vector3(0, 10.2, 0), 0.10, 3.1, Color("#eef1ec"), 8)
	Art.add_static_box(needle, "BaseCollision", Vector3(0, 0.8, 0), Vector3(2.6, 1.6, 2.6), Color("#bbc4bd"), false)
	Art.add_label(needle, "SPACE NEEDLE", Vector3(0, 12.1, 0), 32, Color("#effff7"))


func _build_seattle_waterfront() -> void:
	Art.add_box(self, "ElliottBay", Vector3(0, -0.05, 14.6), Vector3(48, 0.18, 6.4), Color("#3e7f94"), false)
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
	var radius := 3.0
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		var segment := Art.add_box(wheel, "Rim", Vector3(cos(angle) * radius, 3.5 + sin(angle) * radius, 0), Vector3(0.20, 1.25, 0.28), Color("#e9e4d7"))
		segment.rotation_degrees.z = -rad_to_deg(angle)
		if index % 2 == 0:
			Art.add_box(wheel, "Cabin", Vector3(cos(angle) * radius, 3.5 + sin(angle) * radius, 0), Vector3(0.55, 0.55, 0.65), Color("#c84f52"))
		var spoke := Art.add_box(wheel, "Spoke", Vector3(cos(angle) * radius * 0.5, 3.5 + sin(angle) * radius * 0.5, 0), Vector3(0.07, radius, 0.07), Color("#d6d4ca"), false)
		spoke.rotation_degrees.z = -rad_to_deg(angle)
	Art.add_cylinder(wheel, "Axle", Vector3(0, 3.5, 0), 0.33, 1.0, Color("#bf554f"), 10).rotation_degrees.x = 90
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


func _on_ticket_requested(destination: String) -> void:
	travel_requested.emit(destination)


func _on_friend_conversation(friend_id: String, display_name: String) -> void:
	friend_conversation_requested.emit(friend_id, display_name)
