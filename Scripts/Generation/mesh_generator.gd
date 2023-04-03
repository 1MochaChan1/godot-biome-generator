class_name MeshGenerator extends Node

var mesh_arrays:Array = [] # array  of arrays that contains mesh data

var verts = PackedVector3Array() # contains vertex positions.
var uvs = PackedVector2Array() # contains the uvs
var normals = PackedVector3Array() # containts normals
"""
contains sets of 3 integers indicating the order of vertices that makes up one
triangle.
len(indices)/3 = no. of triangles.
"""
var indices = PackedInt32Array() # contains the order of vertices to create △ 

var xsize:int
var zsize:int
var x_offset:float
var z_offset:float
var height:float 
var height_threshold:float
var tiling_factor:float
var height_curve:Curve


func _init(
	x_size:int=40, z_size:int=40,
	x_offset_:float=0, z_offset_:float=0,
	height_:float=20, height_threshold_:float=-0.35,
	height_curve_:Curve = Curve.new(),
	stretch_factor_:float=1):
		
	self.xsize = x_size
	self.zsize = z_size
	self.x_offset = x_offset_
	self.z_offset = z_offset_
	self.height = height_
	self.height_threshold = height_threshold_
	self.height_curve = height_curve_
	self.tiling_factor = stretch_factor_


func create_terrain_mesh(
	mesh:MeshInstance3D,
	noise:Noise) -> MeshInstance3D:
	
	# sizing the arrays.
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	verts.resize((xsize+1)*(zsize+1))
	indices.resize(xsize*zsize*6)
	normals.resize(len(verts))
	uvs.resize(len(verts))
	
	# calling methods to build the mesh.
	
	create_vertices(noise) # maps the vertices
	
	create_indices() # creates indices 3 elements for each triangle.
	
	create_uvs() # creating uvs to apply texture
	
	create_normals() # creates normals by taking cross product
	
	
	mesh_arrays[Mesh.ARRAY_VERTEX] = verts
	mesh_arrays[Mesh.ARRAY_TEX_UV] = uvs
	mesh_arrays[Mesh.ARRAY_INDEX] = indices
	mesh_arrays[Mesh.ARRAY_NORMAL] = normals
	
	mesh.mesh = ArrayMesh.new()
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	return mesh



func create_vertices(noise:Noise):
	var i=0
	for z in range(zsize+1):
		for x in range(xsize+1):
			var noise_val = noise.get_noise_2d(x+x_offset,z+z_offset)
#			var y = normalize_noise(noise_val)*height
#			var y = noise_val*height
			var y = clamp(
				noise_val*height,
				height_threshold*height,
				height)
			var pos:Vector3 = Vector3(x*tiling_factor, y, z*tiling_factor)
			# assign position values to index i in array verts
			verts[i] = pos
#			draw_sphere(pos)
			i += 1


func normalize_noise(noise_val)->float:
	var factor = (-noise_val + 1)*0.5
	return noise_val + factor


func create_indices():
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
		
		# adding vertex normals
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

func create_uvs():
	for i in range(len(verts)):
		var uv = Vector2(float(verts[i].x)/xsize, float(verts[i].z)/zsize) 
		uvs[i] = uv
