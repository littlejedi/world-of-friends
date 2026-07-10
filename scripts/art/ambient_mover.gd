class_name AmbientMover
extends Node3D

var start_position: Vector3
var end_position: Vector3
var travel_seconds: float = 16.0
var bob_height: float = 0.04
var elapsed: float = 0.0


func setup(start: Vector3, end: Vector3, duration: float, bob: float = 0.04) -> void:
	start_position = start
	end_position = end
	travel_seconds = maxf(1.0, duration)
	bob_height = bob
	position = start_position


func _process(delta: float) -> void:
	elapsed += delta
	var phase := fposmod(elapsed / travel_seconds, 2.0)
	var progress := phase if phase <= 1.0 else 2.0 - phase
	var next_position := start_position.lerp(end_position, smoothstep(0.0, 1.0, progress))
	next_position.y += sin(elapsed * 2.1) * bob_height
	position = next_position
