class_name TicketOffice
extends StaticBody3D

signal travel_requested(destination: String)

const Art = preload("res://scripts/art/procedural_factory.gd")

var destination: String = "seattle"
var city_name: String = "Shanghai"


func setup(origin_city: String, destination_id: String) -> void:
	city_name = origin_city
	destination = destination_id


func _ready() -> void:
	name = "%sTicketOffice" % city_name
	add_to_group("interactable")
	_build_office()


func _build_office() -> void:
	var building_color := Color("#d06b5c") if city_name == "Shanghai" else Color("#397e83")
	Art.add_box(self, "Building", Vector3(0, 1.35, 1.45), Vector3(4.6, 2.7, 3.4), building_color)
	Art.add_box(self, "Roof", Vector3(0, 2.88, 1.45), Vector3(5.0, 0.34, 3.8), Color("#29354b"))
	Art.add_box(self, "Door", Vector3(0, 0.92, -0.29), Vector3(1.15, 1.85, 0.12), Color("#f1c86b"), false)
	Art.add_box(self, "WindowL", Vector3(-1.42, 1.45, -0.31), Vector3(0.9, 0.9, 0.08), Color("#8fd4dc"), false)
	Art.add_box(self, "WindowR", Vector3(1.42, 1.45, -0.31), Vector3(0.9, 0.9, 0.08), Color("#8fd4dc"), false)
	# Repeat the facade cues on the camera-facing side of the compact model.
	Art.add_box(self, "DoorCameraSide", Vector3(0, 0.92, 3.19), Vector3(1.15, 1.85, 0.12), Color("#f1c86b"), false)
	Art.add_box(self, "WindowLCameraSide", Vector3(-1.42, 1.45, 3.18), Vector3(0.9, 0.9, 0.08), Color("#8fd4dc"), false)
	Art.add_box(self, "WindowRCameraSide", Vector3(1.42, 1.45, 3.18), Vector3(0.9, 0.9, 0.08), Color("#8fd4dc"), false)
	Art.add_label(self, "%s INTERWORLD\nTICKETS" % city_name.to_upper(), Vector3(0, 3.55, 0.8), 30, Color("#ffe9a8"))
	Art.add_sphere(self, "Beacon", Vector3(0, 3.45, 1.55), 0.22, Color("#f5cf68"), 10, 5)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.6, 2.7, 3.4)
	collision.shape = shape
	collision.position = Vector3(0, 1.35, 1.45)
	add_child(collision)


func get_interaction_prompt() -> String:
	return "Buy a ticket to %s" % destination.capitalize()


func interact(_player: Node3D) -> void:
	travel_requested.emit(destination)
