@tool
class_name EndlessTerrainGenerator extends Node

var terrain_generator = TerrainGenerator.new()

@export var max_view_dist:float = 300
@export var viewer:Node3D : 
	set(val):
		viewer = val
	get:
		return viewer
@export var viewer_position:Vector2

var chunk_size:int
var chunk_visible_in_dist:int
var terrain_chunk_dict:Dictionary = {} # <Vector2, TerrainChunk>
 
func _ready():
	if(viewer==null):
		viewer = get_node("../test_node")
	viewer_position = Vector2(viewer.global_position.x, viewer.global_position.z)
	chunk_size = terrain_generator.MAP_CHUNK_SIZE
	chunk_visible_in_dist = roundi(max_view_dist/chunk_size)

func _process(_delta):
	if(viewer!=null):
		viewer_position = Vector2(viewer.global_position.x, viewer.global_position.z)
		update_visible_chunk()
	else:
		print(viewer)
		pass
	

func update_visible_chunk():
	# If chunk is to the left of the center, i.e. -250.
	# Then current_chunk_coord_x = -1.
	var current_chunk_coord_x = roundi(viewer_position.x/chunk_size)
	var current_chunk_coord_y = roundi(viewer_position.y/chunk_size)
	
	for y_offset in range(-chunk_visible_in_dist, chunk_visible_in_dist):
		for x_offset in range(-chunk_visible_in_dist, chunk_visible_in_dist):
			var view_chunk_coord := Vector2(
				current_chunk_coord_x+x_offset,
				current_chunk_coord_y+y_offset
				)
			if (terrain_chunk_dict.has(view_chunk_coord)):
				terrain_chunk_dict[view_chunk_coord].update_terrain_chunks(viewer_position)
			else:
				terrain_chunk_dict[view_chunk_coord] = TerrainChunk.new(
					view_chunk_coord, chunk_size, max_view_dist
					)
				var returned_mesh_object = terrain_chunk_dict.get(view_chunk_coord).get_mesh()
				var test = MeshInstance3D.new()
				test.mesh = PlaneMesh.new()
				add_child(returned_mesh_object)
				print(returned_mesh_object)


class TerrainChunk extends Node3D:
	var mesh_object:MeshInstance3D
	var position2D:Vector2
	var bounds:Rect2
	var max_view_dist:float
	
	func _init(coord:Vector2, size:int, max_view_dist_:float):
		self.max_view_dist = max_view_dist_
		self.mesh_object = MeshInstance3D.new()
		self.mesh_object.mesh = PlaneMesh.new()
		
		self.position2D = coord*size
		self.bounds = Rect2(position2D, Vector2.ONE*size)
		var position3D := Vector3(position2D.x,0,position2D.y)
		
		
		self.mesh_object.position = position3D
		self.mesh_object.scale = Vector3.ONE * size
	
	func get_mesh():
		return self.mesh_object
	
	func update_terrain_chunks(viewer_pos:Vector2):
		var view_dist_from_nearest_edge = bounds.position.distance_squared_to(
			viewer_pos
			)
		var visible_ = view_dist_from_nearest_edge <= self.max_view_dist
		set_chunk_visible(visible_)
	
	func set_chunk_visible(visible_:bool):
		mesh_object.set_process(visible_)
