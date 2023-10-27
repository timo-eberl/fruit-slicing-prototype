extends Node3D


@export var show_debug_plane : bool = false

@onready var rigid_body = $rigidbody
@onready var collision_area = $rigidbody/collision_area
@onready var mesh_whole = $rigidbody/mesh_whole

var dead_melon_scene = preload ("res://scenes/dead_melon.tscn")
var debug_plane_scene = preload("res://scenes/debug_plane.tscn")


func halve_along_plane(plane : Plane, cutting_direction : Vector3, cutting_speed : float):
	if plane.normal.is_zero_approx():
		push_error("plane.normal can't be zero.")
		return
	
	spawn_halve(plane, cutting_direction, cutting_speed, false)
	spawn_halve(plane, cutting_direction, cutting_speed, true)

	self.queue_free()
	
	if show_debug_plane:
		var plane_local : Plane = plane * rigid_body.global_transform
		var debug_plane_instance : Node3D = debug_plane_scene.instantiate()
		rigid_body.add_child(debug_plane_instance)
		debug_plane_instance.position = plane_local.normal * plane_local.d
		debug_plane_instance.transform.basis = Basis.looking_at(plane_local.normal)
		debug_plane_instance.reparent(get_tree().get_root())


func spawn_halve(plane : Plane, cutting_direction : Vector3, cutting_speed : float, rotate_180 : bool):
	# instantiate a whole melon (without melon logic) that we will chop up
	var melon_halve_instance : Node3D = dead_melon_scene.instantiate()
	get_tree().get_root().add_child(melon_halve_instance)
	melon_halve_instance.global_transform = rigid_body.global_transform
	
	# rotate so the collider ends up on the correct side
	if rotate_180:
		melon_halve_instance.transform.basis = melon_halve_instance.transform.basis.rotated(Vector3(0,1,0), 3.141)
	
	var mesh_node : MeshInstance3D = melon_halve_instance.get_node("rigidbody/scaling/mesh")
	var mesh_resource : ArrayMesh = mesh_node.mesh
	
	# for surface_index in range(mesh.get_surface_count()):
	var surface_index = 0 # for now we have only one surface
	
	# we don't want to edit the resource, so we create a new mesh instance
	var mesh_instance = ArrayMesh.new()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh_resource, surface_index)
	
	var plane_local : Plane = plane * mesh_node.global_transform
	
	# iterate over vertices
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		
		if plane_local.is_point_over(vertex) == rotate_180:
			# collapse geometry
			var approx_center_of_cut = mesh_node.position + plane_local.normal * plane_local.d
			mdt.set_vertex(i, approx_center_of_cut)
	
	# add surface to mesh_instance
	mdt.commit_to_surface(mesh_instance)
	mesh_node.mesh = mesh_instance
	
	# TODO: Slice Mesh more accurately and add material on the inside
	
	# TODO: Change collider and weight based on slice size
	
	var halve_rigid_body : RigidBody3D = melon_halve_instance.get_node("rigidbody")
#	halve_rigid_body.freeze = true # disable physics for testing
	var direction = -plane.normal
	if rotate_180:
		direction = -direction
	# yeet away from cutting point so the halves don't intersect
	halve_rigid_body.apply_central_force(-direction * 70)
	# yeet in cutting direction
	halve_rigid_body.apply_central_force(cutting_direction * 15 * cutting_speed)
	# apply torque in a way that the inside of the fruit always faces the player
	var torque_multiplier = 0.7
	if rotate_180:
		halve_rigid_body.apply_torque(-cutting_direction * torque_multiplier)
	else:
		halve_rigid_body.apply_torque(cutting_direction * torque_multiplier)
		
