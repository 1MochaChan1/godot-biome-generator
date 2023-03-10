@tool
extends Node

@export var xsize:int=4:
	set(val):
		xsize=val
	get:
		return xsize

@export var zsize:int=2:
	set(val):
		zsize=val
	get:
		return zsize

@onready var mesh3D = $MeshInstance3D
@onready var gizmos = $Gizmos

var arrays = []
var gizmos_arrays = []
# PackedVector{**}Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func _ready():
	arrays.resize(Mesh.ARRAY_MAX)
	gizmos_arrays.resize(Mesh.ARRAY_MAX)
	
	_build_mesh()

func _build_mesh():
#	verts.resize((xsize+1)*(zsize+1))
#	indices.resize(xsize*zsize*6)
#	var i=0
#	for x in range(xsize+1):
#		for z in range(zsize+1):
#			verts[i] = Vector3(x, 0, z)
#			i += 1
	
	var vert:int = 0
	var tris:int = 0
	
#	---- Keep this lines of code important ----
#	verts[0] = Vector3(0, 0, 0) 
#	verts[1] = Vector3(0, 0, 1)
#	verts[2] = Vector3(1, 0, 0)
#	verts[3] = Vector3(1, 0, 1)
#	verts[4] = Vector3(2, 0, 0)
#	verts[5] = Vector3(2, 0, 1)
#
#	indices = PackedInt32Array([
#		0,3,1,
#		1,3,4,
#		1,4,2,
#		2,4,5
#		])
#	-------------------------------------------

	verts = PackedVector3Array([
		Vector3(0, 0, 0) ,
		Vector3(0, 0, 1),
		Vector3(1, 0, 0),
#		Vector3(1, 0, 1),
#		Vector3(2, 0, 0),
#		Vector3(2, 0, 1),
		])
	
	indices = PackedInt32Array([
		0,1,2,
#		1,2,3,
#		2,4,3,
#		2,4,5
		])

#	for x in range(xsize):
#		indices[tris+0] = vert+0
#		indices[tris+1] = vert+ xsize + 1
#		indices[tris+2] = vert+1
#		indices[tris+3] = vert+1
#		indices[tris+4] = vert+ xsize + 1
#		indices[tris+5] = vert+ xsize + 2
#
#		vert += 1
#		tris += 6
	
#	for x in range(0,len(indices),3):
#		print(indices[x], indices[x+1], indices[x+2])
#
#	print(verts)
	
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
#	arrays[Mesh.ARRAY_TEX_UV] = uvs
#	arrays[Mesh.ARRAY_NORMAL] = normals
	
	gizmos_arrays[Mesh.ARRAY_VERTEX]=verts
#	gizmos_arrays[Mesh.ARRAY_INDEX] = indices

	mesh3D.mesh = ArrayMesh.new()
	gizmos.mesh = ArrayMesh.new()
	mesh3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	gizmos.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, gizmos_arrays)
	
func set_zsize(new_size:int):
	zsize = new_size
	_build_mesh()
	
func set_xsize(new_size:int):
	xsize = new_size
	_build_mesh()
#
func _process(delta):
	_build_mesh()
	pass
