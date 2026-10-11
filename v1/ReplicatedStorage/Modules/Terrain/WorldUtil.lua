local WorldConfig = require(game.ReplicatedStorage.Modules.Terrain.WorldConfig)
local WorldUtil = {}

function WorldUtil.stringify(key, ...)
	for _, x in pairs({...}) do
		key = key.." "..x
	end
	return key
end

function WorldUtil.getWorldPosition(cx, cy, cz, x, y, z)
	local halfChunkSize = math.floor(WorldConfig.CHUNK_SIZE/2)
	local halfBlockSize = math.floor(WorldConfig.BLOCK_SIZE/2)
	
	local wx = WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cx + z - halfChunkSize) - halfBlockSize
	local wy = WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cy + y - halfChunkSize) - halfBlockSize
	local wz = WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cz + x - halfChunkSize) - halfBlockSize
	
	return wx, wy, wz 
end

function WorldUtil.worldToChunkPosition(position)
	local cx = math.floor(position.X/64 + .5)
	local cy = math.floor(position.Y/64 + .5)
	local cz = math.floor(position.Z/64 + .5)
	return cx, cy, cz
end

function WorldUtil.boundCell(cx, cy, cz, x, y, z)
	local sameChunk = true
	local lBound = 1
	local uBound = WorldConfig.CHUNK_SIZE
	if x < lBound then
		cz -= 1
		x = uBound
		sameChunk = false
	end
	if x > uBound then
		cz += 1
		x = lBound
		sameChunk = false
	end
	if y < lBound then
		cy -= 1
		y = uBound
		sameChunk = false
	end
	if y > uBound then
		cy += 1
		y = lBound
		sameChunk = false
	end
	if z < lBound then
		cx -= 1
		z = uBound
		sameChunk = false
	end
	if z > uBound then
		cx += 1
		z = lBound
		sameChunk = false
	end
	return cx, cy, cz, x, y, z, sameChunk
end

return WorldUtil
