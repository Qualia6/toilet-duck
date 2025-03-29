class_name Door extends Node3D

var state: bool = false

func open() -> void:
	if state: return
	state = true
	%close_sound.stop()
	%AnimationPlayer.play("open")
	%open_sound.play()
	

func close() -> void:
	if not state: return
	state = false
	%AnimationPlayer.play("open", -1, -1, true)
	%close_sound.play()
	%open_sound.stop()
