extends Node3D

var active: bool = false
var count: int = 0

signal activate
signal deactivate

func check_status() -> void:
	var status: bool = count != 0
	if status != active:
		active = status
		if active:
			activate.emit()
		else:
			deactivate.emit()

func _ready() -> void:
	check_status()


func _on_button_body_entered(body: Node3D) -> void:
	count += 1
	check_status()

func _on_button_body_exited(body: Node3D) -> void:
	count -= 1
	check_status()
