class_name WaterCollision extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("_enter_water"):
		body._enter_water()


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("_exit_water"):
		body._exit_water()


func _on_area_entered(area: Area3D) -> void:
	if area.has_method("_enter_water"):
		area._enter_water()


func _on_area_exited(area: Area3D) -> void:
	if area.has_method("_exit_water"):
		area._exit_water()
