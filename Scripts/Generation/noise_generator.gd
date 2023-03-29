
class_name NoiseGenerator extends Node

func generator_noise(
	n_seed,
	octaves:int,
	lacunarity:float=1.25,
	noise_type:int=FastNoiseLite.TYPE_PERLIN) -> FastNoiseLite:
	
	var noise = FastNoiseLite.new() 
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = rand_from_seed(n_seed)[0]
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	
	return noise
