class_name PlayerCharacter
extends CharacterBody3D

signal interact_requested
signal step_taken

const Art = preload("res://scripts/art/procedural_factory.gd")

@export var move_speed: float = 5.2
@export var acceleration: float = 18.0

var control_enabled: bool = true
var visual: Node3D
var walk_time: float = 0.0
var footstep_cooldown: float = 0.0
var wave_tween: Tween
var speech_bubble: Label3D
var speech_tween: Tween


func _ready() -> void:
	name = "Player"
	add_to_group("player")
	_build_collision()
	visual = Art.add_character_visual(
		self,
		0.88,
		Color("#f3b34c"),
		Color("#304c73"),
		Color("#efbd91"),
		Color("#2c2430"),
		false
	)
	speech_bubble = Art.add_label(self, "", Vector3(0, 2.55, 0), 36, Color("#fff4d6"))
	speech_bubble.name = "SpeechBubble"
	speech_bubble.pixel_size = 0.009
	speech_bubble.outline_size = 10
	speech_bubble.visible = false


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if control_enabled:
		input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera := get_viewport().get_camera_3d()
	var movement := Vector3.ZERO
	if camera != null and input_vector.length_squared() > 0.001:
		var camera_forward := -camera.global_basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()
		var camera_right := camera.global_basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()
		movement = (camera_right * input_vector.x + camera_forward * -input_vector.y).normalized()
	var desired := movement * move_speed
	velocity.x = move_toward(velocity.x, desired.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, desired.z, acceleration * delta)
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = -0.5
	move_and_slide()
	if movement.length_squared() > 0.01:
		look_at(global_position + movement, Vector3.UP)
		walk_time += delta * 9.0
		visual.position.y = abs(sin(walk_time)) * 0.045
	else:
		visual.position.y = move_toward(visual.position.y, 0.0, delta * 0.4)
	if movement.length_squared() > 0.01 and Vector2(velocity.x, velocity.z).length() > 0.8 and is_on_floor():
		footstep_cooldown -= delta
		if footstep_cooldown <= 0.0:
			footstep_cooldown = 0.36
			step_taken.emit()
	else:
		footstep_cooldown = 0.0
	if control_enabled and Input.is_action_just_pressed("interact"):
		interact_requested.emit()


func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.65
	collision.shape = shape
	collision.position.y = 0.83
	add_child(collision)


func wave() -> void:
	if visual == null:
		return
	var arm := visual.get_node_or_null("ArmR") as Node3D
	if arm == null:
		return
	if wave_tween != null and wave_tween.is_valid():
		wave_tween.kill()
	arm.rotation_degrees = Vector3.ZERO
	wave_tween = create_tween()
	wave_tween.tween_property(arm, "rotation_degrees", Vector3(0, 0, -105), 0.18).set_trans(Tween.TRANS_BACK)
	wave_tween.tween_property(arm, "rotation_degrees", Vector3(0, 0, -70), 0.13)
	wave_tween.tween_property(arm, "rotation_degrees", Vector3(0, 0, -105), 0.13)
	wave_tween.tween_property(arm, "rotation_degrees", Vector3.ZERO, 0.22)


func greet(target_position: Vector3, words: String = "HELLO!") -> void:
	face_toward(target_position)
	wave()
	say(words)


func face_toward(target_position: Vector3) -> void:
	var direction := target_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.001:
		look_at(global_position + direction, Vector3.UP)


func say(words: String) -> void:
	if speech_bubble == null:
		return
	if speech_tween != null and speech_tween.is_valid():
		speech_tween.kill()
	speech_bubble.text = words
	speech_bubble.modulate = Color("#fff4d6")
	speech_bubble.visible = true
	speech_tween = create_tween()
	speech_tween.tween_interval(1.35)
	speech_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.35)
	speech_tween.tween_callback(func() -> void: speech_bubble.visible = false)
