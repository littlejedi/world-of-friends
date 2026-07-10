class_name FriendNPC
extends CharacterBody3D

signal conversation_requested(friend_id: String, display_name: String)

const Art = preload("res://scripts/art/procedural_factory.gd")

var friend_id: String = "kent"
var display_name: String = "Kent"
var height_scale: float = 0.94
var shirt_color: Color = Color("#4a78ba")
var follow_target: Node3D
var follow_offset: Vector3 = Vector3.ZERO
var visual: Node3D
var walk_time: float = 0.0


func setup(
	new_id: String,
	new_name: String,
	new_height: float,
	new_shirt: Color,
	new_offset: Vector3
) -> void:
	friend_id = new_id
	display_name = new_name
	height_scale = new_height
	shirt_color = new_shirt
	follow_offset = new_offset


func _ready() -> void:
	name = display_name
	add_to_group("interactable")
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.33 * height_scale
	shape.height = 1.65 * height_scale
	collision.shape = shape
	collision.position.y = 0.83 * height_scale
	add_child(collision)
	visual = Art.add_character_visual(
		self,
		height_scale,
		shirt_color,
		Color("#31415f") if friend_id == "kent" else Color("#4b3b62"),
		Color("#e8b78d"),
		Color("#302832"),
		true
	)
	Art.add_label(self, display_name, Vector3(0, 2.42 * height_scale, 0), 28, Color("#fff4d6"))


func _physics_process(delta: float) -> void:
	if follow_target == null:
		velocity = velocity.move_toward(Vector3.ZERO, delta * 12.0)
		move_and_slide()
		return
	var target_position := follow_target.global_position + follow_offset
	var planar_delta := target_position - global_position
	planar_delta.y = 0.0
	var distance := planar_delta.length()
	if distance > 16.0:
		global_position = target_position + Vector3(0, 0.05, 0)
		velocity = Vector3.ZERO
		return
	if distance > 1.65:
		var direction := planar_delta.normalized()
		velocity.x = direction.x * 4.2
		velocity.z = direction.z * 4.2
		look_at(global_position + direction, Vector3.UP)
		walk_time += delta * 8.0
		visual.position.y = abs(sin(walk_time)) * 0.04
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 12.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 12.0)
		visual.position.y = move_toward(visual.position.y, 0.0, delta * 0.4)
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = -0.5
	move_and_slide()


func set_follow_target(new_target: Node3D) -> void:
	follow_target = new_target


func get_interaction_prompt() -> String:
	return "Talk to %s" % display_name


func interact(_player: Node3D) -> void:
	conversation_requested.emit(friend_id, display_name)
