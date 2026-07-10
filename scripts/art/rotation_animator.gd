class_name RotationAnimator
extends Node3D

var radians_per_second: float = 0.08


func setup(speed: float) -> void:
	radians_per_second = speed


func _process(delta: float) -> void:
	rotation.z += radians_per_second * delta
