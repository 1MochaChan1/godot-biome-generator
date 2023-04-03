@tool
extends Node3D
const NoiseGenerator =  preload("res://Scripts/Generation/noise_generator.gd")

var noise_gen:NoiseGenerator = NoiseGenerator.new()
@export var update:bool = true
@onready var plane = $Plane


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(update):
		plane.material_override = create_material()
		update = false

func normalize_noise(noise_val):
	var factor = (-noise_val + 1)/2
	return noise_val + factor

func create_material() -> ORMMaterial3D:
	var noise = noise_gen.generator_noise(100,8,2.05,FastNoiseLite.TYPE_SIMPLEX)
	var noise_img = noise.get_image(300, 300, false, false, false)
	var texture = ImageTexture.create_from_image(noise_img)
	var mat:ORMMaterial3D = ORMMaterial3D.new()
	mat.albedo_texture = texture
	return mat
