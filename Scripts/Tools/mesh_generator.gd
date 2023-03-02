extends MeshInstance3D

var arrays = []
# PackedVector{**}Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func _ready():
	arrays.resize(Mesh.ARRAY_MAX)
	
	
	verts = PackedVector3Array( [
		Vector3(0,0,0), Vector3(0,1,0), Vector3(1,0,0), Vector3(1,1,0),
	])

	indices = PackedInt32Array
#
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
#	arrays[Mesh.ARRAY_TEX_UV] = uvs
#	arrays[Mesh.ARRAY_NORMAL] = normals
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
