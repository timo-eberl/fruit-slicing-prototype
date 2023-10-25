extends MeshInstance3D

static var total_count = 0

func _ready():
	var vertex_count = self.mesh.surface_get_arrays(0)[0].size()
	total_count += vertex_count
	print(self.name, " vertex count: ", vertex_count)
	print("vertex count of all counted meshes: ", total_count)
