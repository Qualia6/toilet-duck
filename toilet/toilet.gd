extends Node3D

var active: bool = false
var count: int = 0
var animation_state: float = 0

signal activate
signal deactivate

func check_status() -> void:
	var status: bool = count != 0
	if status != active:
		active = status
		if active:
			%press.play()
			activate.emit()
		else:
			%release.play()
			deactivate.emit()

func _ready() -> void:
	check_status()

const ANIMATION_SPEED: float = 10.;

func _process(delta: float) -> void:
	if active and animation_state < 1.:
		animation_state += delta * ANIMATION_SPEED
	elif not active and animation_state > 0.:
		animation_state -= delta * ANIMATION_SPEED
	else:
		return
	animation_state = clamp(animation_state, 0, 1)
	var material: ShaderMaterial = %mesh.material_override
	material.set_shader_parameter("depression", animation_state)
		

func _on_button_body_entered(body: Node3D) -> void:
	count += 1
	check_status()

func _on_button_body_exited(body: Node3D) -> void:
	count -= 1
	check_status()
