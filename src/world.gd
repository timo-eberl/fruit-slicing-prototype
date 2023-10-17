extends Node3D

var interface : XRInterface

func _ready():
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("yay")
		
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized")
