class_name Duck extends RigidBody3D


func _on_sleeping_state_changed() -> void:
	if not sleeping:
		%quack_sound.play()

var in_water: int = 0

var SPLASH_EFFECT_CLASS = preload("res://water/splash_effect.tscn")

func _enter_water():
	if in_water == 0:
		var splash = SPLASH_EFFECT_CLASS.instantiate()
		get_tree().current_scene.add_child(splash)
		splash.global_position = global_position
	in_water += 1

func _exit_water():
	in_water -= 1
