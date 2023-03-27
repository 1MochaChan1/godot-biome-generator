@tool
extends Node

var player = preload("res://Scripts/Player/movement.gd")

var noise:FastNoiseLite = FastNoiseLite.new()
var immediate_mesh:ImmediateMesh = ImmediateMesh.new()
#var water = Region.new('water', -0.2,Color.LIGHT_SEA_GREEN)
#var sand = Region.new('sand',-0.1, Color.SANDY_BROWN)
#var land = Region.new('land', 0.5, Color.FOREST_GREEN)
#var mountains = Region.new('mountains', 0.7, Color.ANTIQUE_WHITE)
var person:Person


var img:Image


@export var regions:Array[RegionModel]:
	set(val):
		update=true
		print("set")
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
	get:
		return xsize

@export var zsize:int=40:
	set(val):
		update=true
		zsize=val
	get:
		return zsize

@export var height:float = 20.0:
	set(val):
		update=true
		height=val
	get:
		return height

@export var height_threshold:float = -.35:
	set(val):
		update=true
		height_threshold=val
	get:
		return height_threshold

@export var stretch:float = 1.0:
	set(val):
		update=true
		stretch=val
	get:
		return stretch

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

@export var x_offset:float = 0:
	set(val):
		update=true
		x_offset=val
	get:
		return x_offset

@export var z_offset:float = 0:
	set(val):
		update=true
		z_offset=val
	get:
		return z_offset

@export var show_normal_debug:bool=false:
	set(val):
		update=true
		immediate_mesh.clear_surfaces()
		show_normal_debug = val
	get:
		return show_normal_debug

@onready var mesh3D = $MeshInstance3D

# contains mesh data.
var arrays = []

# contains the vertex position
var verts = PackedVector3Array() 
var uvs = PackedVector2Array() # contains the uvs
var normals = PackedVector3Array() # containts normals
"""
contains sets of 3 integers indicating the order of vertices that makes up one
triangle.
len(indices)/3 = tris.
"""
var indices = PackedInt32Array() 

func _ready():
	immediate_mesh.clear_surfaces()
	arrays.resize(Mesh.ARRAY_MAX)
#	_build_mesh()

func _build_mesh():
	verts.resize((xsize+1)*(zsize+1))
	indices.resize(xsize*zsize*6)
	normals.resize(len(verts))
	uvs.resize(len(verts))
	
	noise.seed = rand_from_seed(noise_seed)[0]
	noise.fractal_octaves = octaves
	
	img = Image.create(xsize, zsize, false, Image.FORMAT_RGB8)
	
	populate_vertices()
	
	create_uvs()
	
	populate_indices()
	
	create_normals()
	
	apply_basic_texture()
	
	if(show_normal_debug):
		draw_debug_normal()
	
#	print(indices)
#	print(verts)
#	for x in range(0,len(indices),3):
#		print(indices[x], indices[x+1], indices[x+2])
	
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_NORMAL] = normals
#	arrays[Mesh.ARRAY_COLOR] = colors
	
	
	mesh3D.mesh = ArrayMesh.new()
	mesh3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)



func _process(_delta):
	if(update):
		_build_mesh()
		update=false

func populate_vertices():
	var i=0
	for z in range(zsize+1):
		for x in range(xsize+1):
			
			var y = clamp(
				noise.get_noise_2d(x+x_offset,z+z_offset)*height,
				height_threshold*height,
				height)
			var pos:Vector3 = Vector3(x*stretch, y, z*stretch)
#			assign position values to index i in array verts
			verts[i] = pos
#			draw_sphere(pos)
			i += 1

func create_uvs():
	for i in range(len(uvs)):
		var uv = Vector2(float(verts[i].x)/xsize,float(verts[i].z)/zsize)
		uvs[i] = uv
	
#	var i:int=0 
#	for z in range(zsize+1):
#		for x in range(xsize+1):
#			var uv = Vector2(float(x)/xsize,float(z)/zsize)
#			uvs[i] = uv
#			i += 1

func apply_basic_texture():
	for z in zsize:
		for x in xsize:
			var noise_val= noise.get_noise_2d(x+x_offset,z+z_offset)
			for i in range(len(regions)):
				var region = regions[i]
				if(i == (len(regions)-1)):
					if((noise_val > regions[i-1].height) and (noise_val <= 1.0)):
						img.set_pixel(x,z,regions[-1].color)
				elif(i==0):
					if(noise_val<=region.height):
						img.set_pixel(x,z,region.color)
					continue
				else:
					if((noise_val > regions[i-1].height) and (noise_val <= region.height)):
						img.set_pixel(x,z,region.color)
					else:
						continue
				
#			print(noise_val)
#			if((noise_val <= -0.2)):
#				img.set_pixel(x,z,Color.NAVY_BLUE)
#			elif((noise_val > -.2) and (noise_val <= -0.1)):
#				img.set_pixel(x,z,Color.SANDY_BROWN)
#			elif(( noise_val > -0.1) and (noise_val <= 0.3)):
#				img.set_pixel(x,z,Color.FOREST_GREEN)
#			elif((noise_val > 0.3) and (noise_val<= 1.0)):
#				img.set_pixel(x,z,Color.ALICE_BLUE)
#			for i in len(regions):
#				var region = regions[i]
#				print("-----")
#				if(noise_val<region.height):
#					print(region.name)
#					img.set_pixel(x,z,region.color)
#					continue
			
			
	var texture := ImageTexture.create_from_image(img)
	var mat:= ORMMaterial3D.new()
	mat.albedo_texture = texture
	mesh3D.material_override = mat



func populate_indices():
	var vert:int = 0
	var tris:int = 0
	
	for _i in range(zsize):
		# each iteration 6 indices = 2 triangles are being added to indices.
		for _j in range(xsize):
			indices[tris+0] = vert
			indices[tris+1] = vert+1
			indices[tris+2] = vert+xsize+1
			indices[tris+3] = vert+1
			indices[tris+4] = vert+xsize+2
			indices[tris+5] = vert+xsize+1
			
			
			
			tris+=6
			vert+=1
		vert+=1
	@warning_ignore("integer_division")
	print("tris: ",len(indices)/3)


func create_normals():
	@warning_ignore("integer_division")
	var tri_count:int = len(indices)/3
	for i in range(tri_count):
		# this makes the `i` shift to the start of the current triangle's index
		# by skipping multiples of 3 (1 triangle(s)) 
		var normal_triangle_index:int = i*3
		
		# accessing the vertices at the given indices.
		var vertex_index_1:int = indices[normal_triangle_index]
		var vertex_index_2:int = indices[normal_triangle_index+1]
		var vertex_index_3:int = indices[normal_triangle_index+2]
		
		var triangle_normal:Vector3 = calculate_surface_normal_from_indices(
			vertex_index_1,
			vertex_index_2,
			vertex_index_3)
		normals[vertex_index_1] += triangle_normal
		normals[vertex_index_2] += triangle_normal
		normals[vertex_index_3] += triangle_normal
	
	for i in range(len(normals)):
		normals[i] = normals[i].normalized()

func calculate_surface_normal_from_indices(
	index_1:int,
	index_2:int,
	index_3:int)->Vector3:
		var point_a:Vector3 = verts[index_1]
		var point_b:Vector3 = verts[index_2]
		var point_c:Vector3 = verts[index_3]
		
		var side_ab:Vector3 = point_b - point_a
		var side_ac:Vector3 = point_c - point_a
		var normal_vec := side_ac.cross(side_ab)
		return normal_vec.normalized()
		


# ------- Debug Tools ------- #
func draw_debug_normal():
	immediate_mesh.clear_surfaces()
	var mesh_ins := MeshInstance3D.new()
	var material := ORMMaterial3D.new()
	material.albedo_color = Color.BLUE
	mesh_ins.mesh = immediate_mesh
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for i in range(len(normals)):
		var start:Vector3 = verts[i] # bottom position of the line
		var end:Vector3 = start + (normals[i]) # tip position of the line
		immediate_mesh.surface_add_vertex(start)
		immediate_mesh.surface_add_vertex(end)
		
	immediate_mesh.surface_end()
	add_child(mesh_ins)

func draw_sphere(pos:Vector3):
	var ins:MeshInstance3D = MeshInstance3D.new()
	add_child(ins)
	ins.position=pos
	var sphere:SphereMesh = SphereMesh.new()
	sphere.radius= 0.1
	sphere.height=0.2
	ins.mesh=sphere
