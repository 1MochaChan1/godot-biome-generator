
class_name NoiseGenerator extends Node

func generator_noise(
	n_seed:int=rand_from_seed(100)[0],
	octaves:int = 8,
	lacunarity:float=2.05,
	noise_type:int=FastNoiseLite.TYPE_SIMPLEX) -> FastNoiseLite:
	
	var noise = FastNoiseLite.new() 
	noise.noise_type = noise_type
	noise.seed = rand_from_seed(n_seed)[0]
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	
	return noise
