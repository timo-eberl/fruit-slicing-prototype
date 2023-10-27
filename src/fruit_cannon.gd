extends Node3D

var melon_scene = preload("res://scenes/melon.tscn")
@export var frequency : float = 1
@export var initial_force : float = 1000

func _ready():
	while true:
		await get_tree().create_timer(1/frequency).timeout
		shoot()

func shoot():
	var melon_instance : Node3D = melon_scene.instantiate()
	get_tree().get_root().add_child(melon_instance)
	melon_instance.global_transform = self.global_transform
	var rigid_body = melon_instance.get_node("rigidbody")
	var force = self.global_transform.basis.z.normalized() * -initial_force
	rigid_body.apply_central_force(force)
