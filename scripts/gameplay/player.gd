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
