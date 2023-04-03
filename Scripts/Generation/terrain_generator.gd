@tool
class_name TerrainGenerator extends Node

const Player = preload("res://Scripts/Player/movement.gd")
const MeshGenerator = preload("res://Scripts/Generation/mesh_generator.gd")
const TextureGenerator = preload("res://Scripts/Generation/texture_generator.gd")
const NoiseGenerator =  preload("res://Scripts/Generation/noise_generator.gd")


#var player = preload("res://Scripts/Player/movement.gd")
var mesh_gen:MeshGenerator = MeshGenerator.new()
var texture_gen:TextureGenerator = TextureGenerator.new()
var noise_gen:NoiseGenerator = NoiseGenerator.new()

var noise:FastNoiseLite
var immediate_mesh:ImmediateMesh = ImmediateMesh.new()


@export var regions:Array[RegionModel]:
	set(val):
		update=true
		regions = val
	get:
		return regions

@export var update:bool=false:
	set(val):
		update=val
	get:
		return update


@export var xsize:int=40:
	set(val):
		update=true
		xsize=val
		mesh_gen.xsize=val
	get:
		return xsize

@export var zsize:int=40:
	set(val):
		update=true
		zsize=val
		mesh_gen.zsize=val
		
	get:
		return zsize

@export var x_offset:float = 0:
	set(val):
		update=true
		x_offset=val
		mesh_gen.x_offset=val
	get:
		return x_offset

@export var z_offset:float = 0:
	set(val):
		update=true
		z_offset=val
		mesh_gen.z_offset=val
	get:
		return z_offset

@export var height:float = 20.0:
	set(val):
		update=true
		height=val
		mesh_gen.height=val
	get:
		return height

@export var height_threshold:float = -.35:
	set(val):
		update=true
		height_threshold=val
		mesh_gen.height_threshold=val
	get:
		return height_threshold

@export var tile:float = 1.0:
	set(val):
		update=true
		tile=val
		mesh_gen.tiling_factor=val
		
	get:
		return tile

@export var noise_seed:int = 100:
	set(val):
		update=true
		noise_seed=val
	get:
		return noise_seed

@export var octaves:int = 4:
	set(val):
		update=true
		octaves=val
	get:
		return octaves

@export var lacunarity:float = 2.05:
	set(val):
		update=true
		lacunarity=val
	get:
		return lacunarity

@export var show_debug_normals:bool=false:
	set(val):
		update=true
		immediate_mesh.clear_surfaces()
		show_debug_normals = val
	get:
		return show_debug_normals



@onready var mesh3D = $MeshInstance3D

func _ready():
	immediate_mesh.clear_surfaces()
	mesh_gen = MeshGenerator.new(
		xsize,
		zsize,
		x_offset,
		z_offset,
	)

func _process(_delta):
	if(update):
		create_terrain()
		update=false

func create_terrain():
	noise = noise_gen.generator_noise(noise_seed, octaves, lacunarity,FastNoiseLite.TYPE_SIMPLEX)
	mesh3D = mesh_gen.create_terrain_mesh(mesh3D,noise)
	mesh3D.material_override= texture_gen.apply_basic_texture(
		xsize,
		zsize,
		x_offset,
		z_offset,
		noise,
		regions)
	
	if(show_debug_normals):
		draw_debug_normal()

# ------- Debug Tools ------- # (will shift later :/)
func draw_debug_normal():
	immediate_mesh.clear_surfaces()
	var mesh_ins := MeshInstance3D.new()
	var material := ORMMaterial3D.new()
	material.albedo_color = Color.BLUE
	mesh_ins.mesh = immediate_mesh
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for i in range(len(mesh_gen.normals)):
		var start:Vector3 = mesh_gen.verts[i] # bottom position of the line
		var end:Vector3 = start + (mesh_gen.normals[i]) # tip position of the line
		immediate_mesh.surface_add_vertex(start)
		immediate_mesh.surface_add_vertex(end)

	immediate_mesh.surface_end()
	add_child(mesh_ins)
#
#func draw_sphere(pos:Vector3):
#	var ins:MeshInstance3D = MeshInstance3D.new()
#	add_child(ins)
#	ins.position=pos
#	var sphere:SphereMesh = SphereMesh.new()
#	sphere.radius= 0.1
#	sphere.height=0.2
#	ins.mesh=sphere
