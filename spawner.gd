extends Node3D

@export var scene_to_create: PackedScene
@export var time_between: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	while true:
		await get_tree().create_timer(time_between).timeout
		var thing = scene_to_create.instantiate()
		get_tree().current_scene.add_child(thing)
		thing.global_position = global_transform * Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
