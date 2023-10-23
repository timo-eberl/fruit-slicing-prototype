extends Node3D

@onready var base : Node3D = $base
@onready var tip : Node3D = $tip


var base_position_on_enter : Vector3
var tip_position_on_enter : Vector3
var time_ms_on_enter : int


func _ready():
	# set the physics framerate very high so fruit hits get registered even with fast blade movement
	# 60 is default, but even at 120 the results are undesirable
	Engine.physics_ticks_per_second = 240

func _on_collision_area_entered(_area : Area3D):
	time_ms_on_enter = Time.get_ticks_msec()
	base_position_on_enter = base.global_position
	tip_position_on_enter = tip.global_position

func _on_collision_area_exited(area : Area3D):
	# wait until the blade has moved
	while tip_position_on_enter == tip.global_position:
		push_warning("Blade has not moved since it entered. Waiting one physics step.")
		await get_tree().physics_frame
	
	var tip_position_on_exit = tip.global_position
	
	# create a plane on which the 3 recorded blade positions lie
	# this plane represents the cut
	var plane = Plane(tip_position_on_exit, tip_position_on_enter, base_position_on_enter)
	
	var cutting_vector = tip_position_on_exit - tip_position_on_enter
	var cutting_distance = cutting_vector.length()
	var cutting_time_s : float = (Time.get_ticks_msec() - time_ms_on_enter) / 1000.0
	var cutting_speed = cutting_distance / cutting_time_s
	var cutting_direction = cutting_vector.normalized()

	area.owner.halve_along_plane(plane, cutting_direction, cutting_speed)
