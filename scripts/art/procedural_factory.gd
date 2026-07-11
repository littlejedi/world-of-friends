class_name ProceduralFactory
extends RefCounted


static func material(color: Color, roughness: float = 0.9, emission: Color = Color.TRANSPARENT) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	result.metallic = 0.0
	result.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	if emission.a > 0.0:
		result.emission_enabled = true
		result.emission = emission
		result.emission_energy_multiplier = 1.8
	return result


static func add_box(
	parent: Node,
	object_name: String,
	position: Vector3,
	size: Vector3,
	color: Color,
	cast_shadow: bool = true
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = object_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material(color)
	instance.mesh = mesh
	instance.position = position
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance


static func add_static_box(
	parent: Node,
	object_name: String,
	position: Vector3,
	size: Vector3,
	color: Color,
	cast_shadow: bool = true
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = position
	parent.add_child(body)
	add_box(body, "Visual", Vector3.ZERO, size, color, cast_shadow)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body


static func add_collision_box(
	parent: Node,
	object_name: String,
	position: Vector3,
	size: Vector3
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = position
	parent.add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body


static func add_cylinder(
	parent: Node,
	object_name: String,
	position: Vector3,
	radius: float,
	height: float,
	color: Color,
	radial_segments: int = 12
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = object_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = radial_segments
	mesh.material = material(color)
	instance.mesh = mesh
	instance.position = position
	parent.add_child(instance)
	return instance


static func add_sphere(
	parent: Node,
	object_name: String,
	position: Vector3,
	radius: float,
	color: Color,
	radial_segments: int = 12,
	rings: int = 6
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = object_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial_segments
	mesh.rings = rings
	mesh.material = material(color)
	instance.mesh = mesh
	instance.position = position
	parent.add_child(instance)
	return instance


static func add_triangular_prism(
	parent: Node,
	object_name: String,
	position: Vector3,
	size: Vector3,
	color: Color
) -> MeshInstance3D:
	var half := size * 0.5
	var vertices := [
		Vector3(-half.x, -half.y, -half.z),
		Vector3(-half.x, -half.y, half.z),
		Vector3(half.x, -half.y, 0),
		Vector3(-half.x, half.y, -half.z),
		Vector3(-half.x, half.y, half.z),
		Vector3(half.x, half.y, 0)
	]
	var indices := [
		0, 2, 1,
		3, 4, 5,
		0, 1, 4, 0, 4, 3,
		0, 3, 5, 0, 5, 2,
		1, 2, 5, 1, 5, 4
	]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in indices:
		surface.add_vertex(vertices[index])
	surface.generate_normals()
	var mesh := surface.commit()
	mesh.surface_set_material(0, material(color))
	var instance := MeshInstance3D.new()
	instance.name = object_name
	instance.mesh = mesh
	instance.position = position
	parent.add_child(instance)
	return instance


static func add_beam(
	parent: Node,
	object_name: String,
	start: Vector3,
	end: Vector3,
	width: float,
	color: Color
) -> MeshInstance3D:
	var midpoint := start.lerp(end, 0.5)
	var beam := add_box(parent, object_name, midpoint, Vector3(width, width, start.distance_to(end)), color)
	var target := (parent as Node3D).to_global(end) if parent is Node3D else end
	beam.look_at(target, Vector3.UP)
	return beam


static func add_label(
	parent: Node,
	text: String,
	position: Vector3,
	font_size: int = 34,
	color: Color = Color.WHITE
) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = position
	label.font_size = font_size
	label.modulate = color
	label.outline_size = 7
	label.outline_modulate = Color(0.04, 0.05, 0.09, 0.94)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	parent.add_child(label)
	return label


static func add_tree(parent: Node, position: Vector3, scale_factor: float = 1.0) -> Node3D:
	var tree := Node3D.new()
	tree.name = "Tree"
	tree.position = position
	parent.add_child(tree)
	add_cylinder(tree, "Trunk", Vector3(0, 0.65 * scale_factor, 0), 0.13 * scale_factor, 1.3 * scale_factor, Color("#76523b"), 8)
	add_sphere(tree, "LeavesLower", Vector3(0, 1.55 * scale_factor, 0), 0.72 * scale_factor, Color("#497b53"), 10, 5)
	add_sphere(tree, "LeavesUpper", Vector3(0.18, 2.05 * scale_factor, -0.08), 0.55 * scale_factor, Color("#67a35f"), 10, 5)
	return tree


static func add_character_visual(
	parent: Node,
	height_scale: float,
	shirt_color: Color,
	pants_color: Color,
	skin_color: Color,
	hair_color: Color,
	has_glasses: bool = false
) -> Node3D:
	var visual := Node3D.new()
	visual.name = "CharacterVisual"
	visual.scale = Vector3.ONE * height_scale
	parent.add_child(visual)
	add_box(visual, "Torso", Vector3(0, 1.05, 0), Vector3(0.72, 0.85, 0.42), shirt_color)
	add_box(visual, "Head", Vector3(0, 1.73, 0), Vector3(0.66, 0.58, 0.58), skin_color)
	add_box(visual, "Hair", Vector3(0, 2.03, -0.02), Vector3(0.69, 0.16, 0.60), hair_color)
	add_box(visual, "LegL", Vector3(-0.20, 0.42, 0), Vector3(0.27, 0.72, 0.32), pants_color)
	add_box(visual, "LegR", Vector3(0.20, 0.42, 0), Vector3(0.27, 0.72, 0.32), pants_color)
	add_box(visual, "ArmL", Vector3(-0.48, 1.04, 0), Vector3(0.22, 0.75, 0.26), shirt_color)
	add_box(visual, "ArmR", Vector3(0.48, 1.04, 0), Vector3(0.22, 0.75, 0.26), shirt_color)
	add_box(visual, "EyeL", Vector3(-0.15, 1.78, -0.302), Vector3(0.08, 0.08, 0.025), Color("#273147"), false)
	add_box(visual, "EyeR", Vector3(0.15, 1.78, -0.302), Vector3(0.08, 0.08, 0.025), Color("#273147"), false)
	if has_glasses:
		add_box(visual, "GlassesL", Vector3(-0.15, 1.78, -0.322), Vector3(0.27, 0.20, 0.025), Color("#182033"), false)
		add_box(visual, "GlassesR", Vector3(0.15, 1.78, -0.322), Vector3(0.27, 0.20, 0.025), Color("#182033"), false)
		add_box(visual, "GlassesBridge", Vector3(0, 1.78, -0.337), Vector3(0.09, 0.035, 0.025), Color("#182033"), false)
	return visual
