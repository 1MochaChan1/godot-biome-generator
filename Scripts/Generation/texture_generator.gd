extends Node
class_name TextureGenerator

func apply_basic_texture(
	xsize:int,
	zsize:int,
	x_offset:float,
	z_offset:float,
	noise:FastNoiseLite,
	regions:Array[RegionModel]) -> ORMMaterial3D:
	
	var img := Image.create(xsize, zsize, false, Image.FORMAT_RGB8)
	
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
	
	var texture := ImageTexture.create_from_image(img)
	var mat:= ORMMaterial3D.new()
	mat.albedo_texture = texture
	return mat
