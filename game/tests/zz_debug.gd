extends Node

func _ready() -> void:
	var scene: PackedScene = preload("res://enemies/bitrot_slime.tscn")
	var slime = scene.instantiate()
	add_child(slime)

	var player := CharacterBody3D.new()
	player.collision_layer = 2
	player.collision_mask = 0
	player.add_to_group("player")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.6
	shape.shape = capsule
	player.add_child(shape)
	add_child(player)
	player.global_position = Vector3(5.0, 0.0, 0.0)

	print("player in group: ", get_tree().get_first_node_in_group("player"))
	print("slime is_inside_tree: ", slime.is_inside_tree())
	print("slime.distance_to_player(): ", slime.distance_to_player())
	print("detect_radius: ", slime.detect_radius)
	slime._physics_process(0.1)
	print("state after physics_process: ", slime.current_state())
	get_tree().quit()
