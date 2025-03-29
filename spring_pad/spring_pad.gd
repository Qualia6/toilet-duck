extends Area3D

@export
var direction: Vector3

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.linear_velocity = direction
		$boing_sound.play()
	elif body is CharacterBody3D:
		body.velocity = direction
		$boing_sound.play()
