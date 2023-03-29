extends Resource
class_name RegionModel

@export var name:String:
	set(val):
		name = val
	get:
		return name

@export_range(-1.0,1.0) var height:float:
	set(val):
		height = val
	get:
		return height

@export var color:Color:
	set(val):
		color = val
	get:
		return color

func _init(v_name:String="", v_height:float=0.0, v_color:Color=Color.ANTIQUE_WHITE):
	self.name = v_name
	self.height = v_height 
	self.color = v_color
