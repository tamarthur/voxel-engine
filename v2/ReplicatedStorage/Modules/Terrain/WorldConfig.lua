local blockSize = 4
local terrainRange = 64

local Config = {
	BLOCK_SIZE = blockSize,
	CHUNK_SIZE = blockSize^2,
	
	WORLD_ALTITUDE_BLOCKS = 64,
	WORLD_ALTITUDE = 4,
	
	WORLD_HEIGHT = 8,
	WORLD_DEPTH = -16,
	
	--TERRAIN_HEIGHT = 256,
	--TERRAIN_DEPTH = -256,
	TERRAIN_RANGE = terrainRange,
	TERRAIN_MAGNITUDE = 2*terrainRange,
		
	--Max size in chunks
	WORLD_SIZE = 6,
}

return Config
