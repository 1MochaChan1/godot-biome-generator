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
var stretch_factor:float
var level_of_detail:int

var _mesh_simplification_increment:int 
var _vertices_per_line:int # the width of the mesh.

var _triangles:int

func _init(
	x_size:int=40, z_size:int=40,level_of_detail_:int=0,
	x_offset_:float=0, z_offset_:float=0,
	height_:float=20, height_threshold_:float=-0.35,
	stretch_factor_:float=1):
		
	self.xsize = x_size
	self.zsize = z_size
	self.level_of_detail=level_of_detail_
	self.x_offset = x_offset_
	self.z_offset = z_offset_
	self.height = height_
	self.height_threshold = height_threshold_
	self.stretch_factor = stretch_factor_


func create_terrain_mesh(
	mesh:MeshInstance3D,
	noise:Noise) -> MeshInstance3D:
	
	# sizing the arrays.
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	####################################################
	# • --- •                                          #
	# |     |                                          #
	# • --- • <--- Each quad requires n+1 vertices.    #
	####################################################
	verts.resize((xsize+1)*(zsize+1))
	
	# Each quad requires 2 triangles
	# 2 triangles = 6 vertices.
	indices.resize(xsize*zsize*6)
	uvs.resize((xsize+1)*(zsize+1))
	normals.resize((xsize+1)*(zsize+1))
	
	
	# calling methods to build the mesh.
	_mesh_simplification_increment = 1 if level_of_detail == 0 else level_of_detail * 2
	@warning_ignore("integer_division")
	_vertices_per_line = ((xsize-1)/ _mesh_simplification_increment) + 1
	
	create_vertices(noise) # maps the vertices
	
	create_normals() # creates normals by taking cross product
	
	create_uvs() # creating uvs to apply texture
	
	
	mesh_arrays[Mesh.ARRAY_VERTEX] = verts
	mesh_arrays[Mesh.ARRAY_INDEX] = indices
	mesh_arrays[Mesh.ARRAY_TEX_UV] = uvs
	mesh_arrays[Mesh.ARRAY_NORMAL] = normals
	print(len(indices)/3)
	mesh.mesh = ArrayMesh.new()
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	return mesh

func create_vertices(noise:Noise):
	var i=0
	_triangles = 0
	for z in range(0,zsize+1,_mesh_simplification_increment):
		for x in range(0,xsize+1,_mesh_simplification_increment):
			var y = clamp(
				noise.get_noise_2d(
					x+x_offset,z+z_offset)*height,
					height_threshold*height,
					height)
			var pos:Vector3 = Vector3(x*stretch_factor, y, z*stretch_factor)
			
			# assigns position values to index i in array verts
			verts[i] = pos
			
			# creates indices, 3 elements for each triangle.
			if(x < xsize && z < zsize):
				_calculate_and_create_index(i)
			
#			draw_sphere(pos)
			i += 1



func _calculate_and_create_index(vertex_index):
	indices[_triangles+0] = vertex_index
	indices[_triangles+1] = vertex_index+1
	indices[_triangles+2] = vertex_index+_vertices_per_line+1
	indices[_triangles+3] = vertex_index+1
	indices[_triangles+4] = vertex_index+_vertices_per_line+2
	indices[_triangles+5] = vertex_index+_vertices_per_line+1
	_triangles += 6


#func create_indices(): #TODO: shift this in create_vertices.
#	var vert:int = 0
#	var tris:int = 0
#	for _i in range(0,zsize,_mesh_simplification_increment):
#		# each iteration 6 indices = 2 triangles are being added to indices.
#		for _j in range(0,zsize,_mesh_simplification_increment):
#			indices[tris+0] = vert
#			indices[tris+1] = vert+1
#			indices[tris+2] = vert+_vertices_per_line+1
#			indices[tris+3] = vert+1
#			indices[tris+4] = vert+_vertices_per_line+2
#			indices[tris+5] = vert+_vertices_per_line+1
#
#			tris+=6
#			vert+=1
#		vert+=1
#	@warning_ignore("integer_division")
	



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
