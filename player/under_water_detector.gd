extends Area3D

var in_water: int = 0

func _enter_water():
	in_water += 1
	update_water_effect()

func _exit_water():
	in_water -= 1
	update_water_effect()

func update_water_effect():
	%water_effect.visible = in_water != 0
