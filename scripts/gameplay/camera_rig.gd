class_name DiagonalCameraRig
extends Node3D

@export var target_path: NodePath
@export var min_size: float = 9.5
@export var max_size: float = 20.0
@export var zoom_step: float = 1.5

var target: Node3D
var camera: Camera3D


func _ready() -> void:
	rotation_degrees = Vector3(-35.264, 45.0, 0.0)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.position = Vector3(0, 0, 20)
	camera.current = true
	add_child(camera)
	if not target_path.is_empty():
		target = get_node_or_null(target_path)


func set_target(new_target: Node3D) -> void:
	target = new_target


func _process(_delta: float) -> void:
	if target != null:
		var desired := target.global_position
		# Quantizing the camera anchor reduces low-resolution pixel shimmer.
		desired.x = snappedf(desired.x, 0.025)
		desired.y = snappedf(desired.y + 0.85, 0.025)
		desired.z = snappedf(desired.z, 0.025)
		global_position = desired
	if Input.is_action_just_pressed("zoom_in"):
		camera.size = maxf(min_size, camera.size - zoom_step)
	if Input.is_action_just_pressed("zoom_out"):
		camera.size = minf(max_size, camera.size + zoom_step)
