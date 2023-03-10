@tool
extends Node

var noise:FastNoiseLite = FastNoiseLite.new()

@export var update:bool=false:
	set(val):
		update=val
	get:
		return update

@export var xsize:int=40:
	set(val):
		xsize=val
	get:
		return xsize

@export var zsize:int=40:
	set(val):
		zsize=val
	get:
		return zsize

@export var height:float = 20.0:
	set(val):
		height=val
	get:
		return height

@export var stretch:float = 1.0:
	set(val):
		stretch=val
	get:
		return stretch

@export var seed:int = 100:
	set(val):
		seed=val
	get:
		return seed

@export var octaves:int = 4:
	set(val):
		octaves=val
	get:
		return octaves


@onready var mesh3D = $MeshInstance3D

var arrays = []
# PackedVector{**}Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func _ready():
	arrays.resize(Mesh.ARRAY_MAX)
	
	
	_build_mesh()

func _build_mesh():
	verts.resize((xsize+1)*(zsize+1))
	indices.resize(xsize*zsize*6)
	noise.seed = rand_from_seed(seed)[0]
	noise.fractal_octaves = octaves
	var i=0
	for x in range(zsize+1):
		for z in range(xsize+1):
			
			var y = clamp(noise.get_noise_2d(x,z)*height, -0.35*height, height)
			var pos:Vector3 = Vector3(x*stretch, y, z*stretch)
			verts[i] = pos
#			draw_sphere(pos)
			i += 1
	
	var vert:int = 0
	var tris:int = 0
	
	for z in range(zsize):
		for x in range(xsize):
			indices[tris+0] = vert+0
			indices[tris+1] = vert+xsize+1
			indices[tris+2] = vert+1
			indices[tris+3] = vert+1
			indices[tris+4] = vert+xsize+1
			indices[tris+5] = vert+xsize+2
			
			tris+=6
			vert+=1
		vert+=1
	
#	print(verts)
#	for x in range(0,len(indices),3):
#		print(indices[x], indices[x+1], indices[x+2])

	
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	

	mesh3D.mesh = ArrayMesh.new()
	mesh3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	

func draw_sphere(pos:Vector3):
	var ins:MeshInstance3D = MeshInstance3D.new()
	add_child(ins)
	ins.position=pos
	var sphere:SphereMesh = SphereMesh.new()
	sphere.radius= 0.1
	sphere.height=0.2
	ins.mesh=sphere

func _process(delta):
	if(update):
		_build_mesh()
		update=false
