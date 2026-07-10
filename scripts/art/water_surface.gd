class_name WaterSurface
extends MeshInstance3D


func setup(surface_size: Vector2, deep_color: Color, highlight_color: Color) -> void:
	var box := BoxMesh.new()
	box.size = Vector3(surface_size.x, 0.18, surface_size.y)
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 deep_color : source_color;
uniform vec4 highlight_color : source_color;

void fragment() {
	float long_wave = sin(UV.x * 44.0 + UV.y * 17.0 + TIME * 1.25);
	float cross_wave = sin(UV.y * 61.0 - TIME * 0.85);
	float glint = smoothstep(0.72, 0.96, long_wave * 0.62 + cross_wave * 0.38);
	ALBEDO = mix(deep_color.rgb, highlight_color.rgb, glint * 0.55);
	EMISSION = highlight_color.rgb * glint * 0.10;
	ROUGHNESS = 0.48;
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("deep_color", deep_color)
	shader_material.set_shader_parameter("highlight_color", highlight_color)
	box.material = shader_material
	mesh = box
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
