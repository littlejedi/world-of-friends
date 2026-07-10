class_name LandmarkInteractable
extends Node3D

signal info_requested(landmark_id: String, title: String, description: String)

const Art = preload("res://scripts/art/procedural_factory.gd")

var landmark_title: String = "Landmark"
var landmark_id: String = "landmark"
var description: String = ""


func setup(id: String, title: String, body: String) -> void:
	landmark_id = id
	landmark_title = title
	description = body


func _ready() -> void:
	name = "%sPlaque" % landmark_title.replace(" ", "")
	add_to_group("interactable")
	Art.add_box(self, "PlaquePost", Vector3(0, 0.42, 0), Vector3(0.12, 0.84, 0.12), Color("#3d4650"), false)
	Art.add_box(self, "Plaque", Vector3(0, 0.92, 0), Vector3(0.72, 0.42, 0.12), Color("#e0b85d"), false)
	Art.add_label(self, "◆", Vector3(0, 1.42, 0), 23, Color("#ffe7a0"))


func get_interaction_prompt() -> String:
	return "View %s" % landmark_title


func interact(_player: Node3D) -> void:
	info_requested.emit(landmark_id, landmark_title, description)
