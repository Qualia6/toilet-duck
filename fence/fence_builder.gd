@tool
extends Path3D

@export_tool_button("Generate", "Callable") var generate_action = generate
@export var distance: float = 1
@export var fence_scene: PackedScene

#func _physics_process(delta: float) -> void:
	#generate()

func kill_children():
	for child in get_children():
		remove_child(child)
		child.queue_free()


func create_cast() -> RayCast3D:
	var cast: RayCast3D = RayCast3D.new()
	cast.target_position = Vector3(0, -20, 0)
	add_child(cast)
	cast.owner = get_tree().edited_scene_root
	return cast


func place_fence(start: Vector3, end: Vector3, normal: Vector3):	
	var fence: Node3D = fence_scene.instantiate()
	
	var tangent: Vector3 = (end - start).cross(normal).normalized()
	var real_normal: Vector3 = normal #(start - end).cross(tangent).normalized()
	
	add_child(fence)
	fence.owner = get_tree().edited_scene_root
	
	fence.global_position = start
	
	fence.global_basis.x = (end - start) / 4
	var size: float = start.distance_to(end)
	fence.global_basis.y = real_normal #* size / 4
	fence.global_basis.z = tangent / 4

func generate():
	#print($eee.is_colliding())
	kill_children()
	var cast: RayCast3D = create_cast()
	cast.target_position = Vector3(0, -100, 0)
	#var i = 0
	for i in range(floor(curve.get_baked_length() / distance)):
		var position1: Vector3 = global_transform * curve.sample_baked(i * distance)
		var position2: Vector3 = global_transform * curve.sample_baked((i+1) * distance)
		var normal: Vector3 = Vector3.UP
		
		#normal -= curve.sample_baked_up_vector(i * distance) * 0.5
		#normal -= curve.sample_baked_up_vector((i+1) * distance) * 0.5
		cast.global_position = position1
		cast.force_raycast_update()
		if cast.is_colliding():
			position1 = cast.get_collision_point()
			normal += cast.get_collision_normal()
		cast.global_position = position2
		cast.force_raycast_update()
		if cast.is_colliding():
			position2 = cast.get_collision_point()
			normal += cast.get_collision_normal()
		if normal.is_zero_approx():
			normal = Vector3.UP
		
		place_fence(position1, position2, normal.normalized())
	
	remove_child(cast)
	cast.queue_free()
