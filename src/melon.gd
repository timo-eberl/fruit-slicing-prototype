extends Node3D


@export var show_debug_plane : bool = false

@onready var collision_area = $collision_area
@onready var mesh_whole = $mesh_whole

var melon_halve_scene = preload("res://scenes/melon_halve.tscn")
var debug_plane_scene = preload("res://scenes/debug_plane.tscn")


func halve_along_plane(plane : Plane, cutting_direction : Vector3, cutting_speed : float):
	if plane.normal.is_zero_approx():
		push_error("plane.normal can't be zero.")
		return

	spawn_halve(plane.normal, cutting_direction, cutting_speed)
	spawn_halve(-plane.normal, cutting_direction, cutting_speed)

	self.queue_free()

	if show_debug_plane:
		var debug_plane_instance = debug_plane_scene.instantiate()
		get_tree().get_root().add_child(debug_plane_instance)
		debug_plane_instance.global_position = self.global_position
		debug_plane_instance.transform.basis = Basis.looking_at(plane.normal)
		await get_tree().create_timer(1).timeout
		debug_plane_instance.queue_free()


func spawn_halve(direction : Vector3, cutting_direction : Vector3, cutting_speed : float):
	var melon_halve_instance : Node3D = melon_halve_scene.instantiate()
	get_tree().get_root().add_child(melon_halve_instance)
	melon_halve_instance.global_position = self.global_position
	melon_halve_instance.transform.basis = Basis.looking_at(direction)

	var rigid_body : RigidBody3D = melon_halve_instance.get_node("rigidbody")
	# move away from cutting point
	rigid_body.apply_central_force(-direction * 40)
	# move in cutting direction
	rigid_body.apply_central_force(cutting_direction * 10 * cutting_speed)

	var camera_direction = Vector3(0,0,-1) # assumption
	var torque = direction.cross(camera_direction)
	rigid_body.apply_torque(torque.normalized() * 0.2)
