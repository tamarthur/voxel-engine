local WorldConfig = require(game.ReplicatedStorage.Modules.Terrain.WorldConfig)
local WorldUtil = {}

WorldUtil.NormalDirections = {{1,0,0}, {0,1,0}, {0,0,1}, {-1,0,0}, {0,-1,0}, {0,0,-1}}
WorldUtil.EdgeDirections = {{-1, -1, -1},{-1, -1, 0},{-1, -1, 1},{-1, 0, -1},{-1, 0, 1},{-1, 1, -1},{-1, 1, 0},{-1, 1, 1},	{0, -1, -1},{0, -1, 1},{0, 1, -1},{0, 1, 1},{1, -1, -1},{1, -1, 0},{1, -1, 1},{1, 0, -1},{1, 0, 1},{1, 1, -1},{1, 1, 0},{1, 1, 1},}

function WorldUtil.bisectionMethod(condition)
	
end

function WorldUtil.loopThroughChunk(callback)
	for x = 1, WorldConfig.CHUNK_SIZE do
		for z = 1, WorldConfig.CHUNK_SIZE do
			for y = 1, WorldConfig.CHUNK_SIZE do
				--if callback returns true, then break
				if callback(x, y, z) then return x, y, z end
			end
		end
	end
end

function WorldUtil.coordinateToKey(...)
	return table.concat({...}, " ")
end

function WorldUtil.keyToCoordinate(key)
	local numbers = string.split(key, " ")
	for i, n in pairs(numbers) do
		numbers[i] = tonumber(n)
	end
	return table.unpack(numbers)
end

function WorldUtil.getBlockNumber(cx, x)
	return WorldConfig.CHUNK_SIZE*cx + x
end

function WorldUtil.getWorldNumber(cx, x)
	local halfChunkSize = math.floor(WorldConfig.CHUNK_SIZE/2)
	local halfBlockSize = math.floor(WorldConfig.BLOCK_SIZE/2)
	
	return WorldConfig.BLOCK_SIZE * (WorldUtil.getBlockNumber(cx, x) - halfChunkSize) - halfBlockSize
	--return WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cx + x - halfChunkSize) - halfBlockSize
end

function WorldUtil.getWorldPosition(cx, cy, cz, x, y, z)
	local wx = WorldUtil.getWorldNumber(cx, z)
	local wy = WorldUtil.getWorldNumber(cy, y)
	local wz = WorldUtil.getWorldNumber(cz, x)
	
	return wx, wy, wz 
end

function WorldUtil.getWorldBlockPosition(cx, cy, cz, x, y, z)
	local wx = WorldUtil.getBlockNumber(cx, z)
	local wy = WorldUtil.getBlockNumber(cy, y)
	local wz = WorldUtil.getBlockNumber(cz, x)

	return wx, wy, wz 
end

--function WorldUtil.worldToChunkPosition(wx, wy, wz)
--	local halfChunkSize = math.floor(WorldConfig.CHUNK_SIZE/2)
--	local halfBlockSize = math.floor(WorldConfig.BLOCK_SIZE/2)

--	local ((wx + halfBlockSize)/WorldConfig.BLOCK_SIZE + z - halfChunkSize)/WorldConfig.CHUNK_SIZE = cx
--	local wy = WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cy + y - halfChunkSize) - halfBlockSize
--	local wz = WorldConfig.BLOCK_SIZE*(WorldConfig.CHUNK_SIZE*cz + x - halfChunkSize) - halfBlockSize

--	return wx, wy, wz 
--end

function WorldUtil.globalToChunkPosition(position)
	local cx = math.floor(position.X/64 + .5)
	local cy = math.floor(position.Y/64 + .5)
	local cz = math.floor(position.Z/64 + .5)
	return cx, cy, cz
end

function WorldUtil.boundNumber(cx, x)
	local sameChunk = true
	local lBound = 1
	local uBound = WorldConfig.CHUNK_SIZE
	if x < lBound then
		cx -= 1
		x = uBound
		sameChunk = false
	end
	return cx, x
end

function WorldUtil.boundCell(cx, cy, cz, x, y, z)	
	local sameChunk = true
	local lBound = 1
	local uBound = WorldConfig.CHUNK_SIZE
	if x < lBound then
		cz -= 1
		x += uBound
		sameChunk = false
	end
	if x > uBound then
		cz += 1
		x -= uBound
		sameChunk = false
	end
	if y < lBound then
		cy -= 1
		y += uBound
		sameChunk = false
	end
	if y > uBound then
		cy += 1
		y -= uBound
		sameChunk = false
	end
	if z < lBound then
		cx -= 1
		z += uBound
		sameChunk = false
	end
	if z > uBound then
		cx += 1
		z -= uBound
		sameChunk = false
	end
	return cx, cy, cz, x, y, z, sameChunk
end

--print(WorldUtil.boundCell(1, 1, 1, 17, 17, 17))

return WorldUtil
