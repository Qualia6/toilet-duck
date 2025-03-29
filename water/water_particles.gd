extends GPUParticles3D

func _ready() -> void:
	$splash_sound.play()
	emitting = true

func _on_finished() -> void:
	queue_free()
