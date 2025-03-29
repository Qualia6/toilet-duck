class_name Player extends RigidBody3D

var last_step_position: Vector3 = position
var last_step_valid: bool = false
const STEP_RANGE: float = 3


@export_range(0.25, 1.) var max_slope: float = 0.8 # cos(max_angle) = this 


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var scaled_mouse_movement: Vector2 = event.relative * -0.00002 * %Camera3D.fov
		%Camera3D.rotate_y(scaled_mouse_movement.x)
		%Camera3D.rotation.x = clamp(%Camera3D.rotation.x + scaled_mouse_movement.y, -PI/2, PI/2)
	if event is InputEventMouseButton:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.is_action_pressed("ui_accept"):
			try_to_interact()
		if event.is_action_pressed("zoom"):
			%zoom_in_sound.play()
		if event.is_action_released("zoom"):
			%zoom_out_sound.play()


func play_step_sound() -> void:
	var sound_areas = %step_sound_selector.get_overlapping_areas()
	if sound_areas.size() == 0: return
	
	var highest_priority_sound_area: StepSoundArea = sound_areas[0]
	for sound_area in sound_areas:
		if sound_area.sound_priority > highest_priority_sound_area.sound_priority:
			highest_priority_sound_area = sound_area
	
	highest_priority_sound_area.play(global_position)


func is_on_ground() -> bool:
	var collision_count: int = %ground_detector.get_collision_count()
	if collision_count == 0: return false
	var normal: Vector3
	if collision_count == 1:
		normal = %ground_detector.get_collision_normal(0)
	else:
		normal = (%ground_detector.get_collision_normal(0) + %ground_detector.get_collision_normal(1)).normalized()
	var slope = normal.dot(Vector3(0, 1, 0));
	return slope > max_slope

func _physics_process(delta: float) -> void:
	if in_water == 0:
		if is_on_ground():
			if not last_step_valid:
				last_step_position = position
				last_step_valid = true
			elif (position - last_step_position).length() >= STEP_RANGE:
					last_step_position = position
					play_step_sound()
			
			var goal_speed: Vector2 = Vector2(0,0)
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var foward_dir: Vector3 = - %Camera3D.basis.x
				goal_speed = Vector2(foward_dir.x,foward_dir.z).normalized() * 12.
			var applied: Vector2 = (goal_speed - Vector2(linear_velocity.x, linear_velocity.z)).normalized() * 25.
			apply_central_force(Vector3(applied.x, 0, applied.y))
		else:
			last_step_valid = false
	else:
		last_step_valid = false
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			apply_central_force(-%Camera3D.basis.x * 10.)


func _process(delta: float) -> void:
	var goal_fov: float = 10 if Input.is_action_pressed("zoom") else 70
	%Camera3D.fov = lerp(%Camera3D.fov, goal_fov, delta * 6)


var DUCK_CLASS = preload("res://duck/rubber_duck.tscn")


func try_to_interact() -> void:	
	if not %RayCast3D.is_colliding(): return
	var collider: Node3D = %RayCast3D.get_collider()
	if %holding_duck.visible:
		if collider.get_meta("cant_place", false): return
		var place_location: Vector3
		var place_rotation: Vector3 = Vector3(0, %Camera3D.global_rotation.y, 0)
		if collider is PlacementHelper:
			place_location = collider.global_position
			if collider.copy_rotation:
				place_rotation = collider.global_basis.get_euler()
		else:
			place_location = %RayCast3D.get_collision_point() + %RayCast3D.get_collision_normal() * 0.5
		var duck = DUCK_CLASS.instantiate()
		get_tree().current_scene.add_child(duck)
		duck.global_position = place_location
		duck.global_rotation = place_rotation
		%holding_duck.visible = false
		%blow_duck_sound.play()
	else:
		if collider == null: return
		if not collider.get_meta("isDuck", false): return
		collider.get_parent().queue_free()
		%holding_duck.visible = true
		%suck_duck_sound.play()
	
	if %holding_duck.visible:
		%RayCast3D.collision_mask |= 0b1000
	else:
		%RayCast3D.collision_mask &= -1- 0b1000


var SPLASH_EFFECT_CLASS = preload("res://water/splash_effect.tscn")

var in_water: int = 0


func _enter_water():
	if in_water == 0:
		var splash = SPLASH_EFFECT_CLASS.instantiate()
		get_tree().current_scene.add_child(splash)
		splash.global_position = global_position
	in_water += 1

func _exit_water():
	in_water -= 1
