extends MeshInstance3D

var animation_t: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animation_t += delta
	var material: ShaderMaterial = material_override
	material.set_shader_parameter("animation", animation_t)
