extends Node3D

@onready var interface : XRInterface = XRServer.find_interface("OpenXR")
@onready var window_title = get_window().title

func _ready():
	if interface and interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized. Is your VR headset connected?")

func _process(_delta):
	# show fps in window title
	get_window().title = window_title + " | FPS: " + str(Engine.get_frames_per_second())
