extends Node3D

@onready var base : Node3D = $base
@onready var tip : Node3D = $tip


var base_position_on_enter : Vector3
var tip_position_on_enter : Vector3
var time_ms_on_enter : int

func _on_collision_area_entered(_area : Area3D):
	time_ms_on_enter = Time.get_ticks_msec()
	base_position_on_enter = base.global_position
	tip_position_on_enter = tip.global_position


func _on_collision_area_exited(area : Area3D):
	var tip_position_on_exit = tip.global_position

	# determine the normal of the plane on which the 3 recorded blade positions lie
	# this plane represents the cut
	var normal = get_normal_of_surface_containing_points(
		tip_position_on_exit, tip_position_on_enter, base_position_on_enter
	)
	
	var cutting_vector = tip_position_on_exit - tip_position_on_enter
	var cutting_distance = cutting_vector.length()
	var cutting_time_s : float = (Time.get_ticks_msec() - time_ms_on_enter) / 1000.0
	var cutting_speed = cutting_distance / cutting_time_s
	var cutting_direction = cutting_vector.normalized()

	area.owner.halve_along_plane(normal, cutting_direction, cutting_speed)

func get_normal_of_surface_containing_points(pos_1 : Vector3, pos_2 : Vector3, pos_3 : Vector3) -> Vector3:
	# calculate two line segments on the surface
	var line_seg_1 = pos_1 - pos_2
	var line_seg_2 = pos_1 - pos_3
	
	return line_seg_1.cross(line_seg_2)
	
