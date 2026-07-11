class_name IsometricPlayer
extends CharacterBody2D

@export var move_speed := 108.0

var movement_bounds := Rect2(34, 181, 572, 143)
var walk_time := 0.0
var facing := Vector2(0, 1)


func _ready() -> void:
	name = "IsometricPlayer"
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 7.0
	shape.height = 18.0
	collision.shape = shape
	collision.position = Vector2(0, -8)
	add_child(collision)
	queue_redraw()


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	velocity = input.normalized() * move_speed
	if input.length_squared() > 0.01:
		facing = input.normalized()
		walk_time += delta * 10.0
	else:
		walk_time = 0.0
	move_and_slide()
	global_position.x = clampf(global_position.x, movement_bounds.position.x, movement_bounds.end.x)
	global_position.y = clampf(global_position.y, movement_bounds.position.y, movement_bounds.end.y)
	queue_redraw()


func _draw() -> void:
	var bob := -absf(sin(walk_time)) * 2.0 if walk_time > 0.0 else 0.0
	var stride := sin(walk_time) * 3.0 if walk_time > 0.0 else 0.0
	draw_colored_polygon(PackedVector2Array([Vector2(-12, 1), Vector2(0, -4), Vector2(14, 1), Vector2(1, 6)]), Color(0.11, 0.12, 0.12, 0.32))
	draw_rect(Rect2(-8 + stride, -15 + bob, 6, 15), Color("#263c52"))
	draw_rect(Rect2(2 - stride, -15 + bob, 6, 15), Color("#304c67"))
	draw_rect(Rect2(-9, -34 + bob, 18, 22), Color("#d8a93e"))
	draw_rect(Rect2(-12, -32 + bob, 4, 16), Color("#bd8a32"))
	draw_rect(Rect2(8, -32 + bob, 4, 16), Color("#edc05a"))
	draw_rect(Rect2(-8, -47 + bob, 16, 15), Color("#d9a77f"))
	draw_rect(Rect2(-9, -50 + bob, 18, 6), Color("#2c2730"))
	draw_rect(Rect2(-10, -47 + bob, 4, 7), Color("#2c2730"))
	var eye_x := 2.0 if facing.x >= 0.0 else -5.0
	draw_rect(Rect2(eye_x, -42 + bob, 2, 2), Color("#2e2830"))
	draw_rect(Rect2(-5, -35 + bob, 10, 3), Color("#f0c76b"))
