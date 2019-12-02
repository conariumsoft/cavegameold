local terrainMath = require("src.terrain")

local biome_rolls = {
	[1] = "plains", 
	[2] = "forest",
	[3] = "plains",
	[4] = "desert",
	[5] = "plains",
	[6] = "wetlands",
	[7] = "forest",
	[8] = "desert",
	[9] = "wetlands",
	
}


return {
    biomes = biome_rolls,
    getBiome = function(x)
        local biome_noise = terrainMath.getBiomeNoise(x)
        local scaled = math.max( math.floor(biome_noise * #biome_rolls), 1)
        
        return biome_rolls[scaled]
    end
}