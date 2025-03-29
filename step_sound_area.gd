class_name StepSoundArea extends Area3D

@export var sound_priority: float = 1.
@export var sound: AudioStreamPlayer3D

func play(global_location: Vector3) -> void:
	sound.global_position = global_location
	sound.play()
