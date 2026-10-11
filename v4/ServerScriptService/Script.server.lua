--!strict

local WorldGeneration = require(game.ServerStorage.Modules.WorldGeneration)
local Chunk = require(game.ServerStorage.Modules.Chunk)
type ChunkInstance = Chunk.ChunkInstance

--local chunk: ChunkInstance = Chunk.new(0,0,0)

--chunk:Iterate(function(x, y, z)
	
--	if y == 16 or y == 1 then
--		chunk:Set(x, y, z, 1)
--	end
--end)

print(WorldGeneration.WorldToChunkSpace(Vector3.new(63,63,63)))

function createChunk(cx, cz)
	local chunk = Chunk.new(cx, 0, cz)
	for x = 1, 16 do
		for z = 1, 16 do
			local worldPosition = WorldGeneration.BlockToWorldSpace(chunk.Position, Vector3.new(x, 8, z))
			local surfaceValue = 0--WorldGeneration.SurfaceMap(worldPosition.X, worldPosition.Z)
			--local discretizedValue = WorldGeneration.Discretize(surfa)
			--print(math.floor(surfaceValue + 3))
			chunk:Set(x, math.floor(surfaceValue + 3), z, 1)
		end
	end	
	chunk:Load()
end

--createChunk(0, 0)

local chunks = {}
for cx = -1, 1 do
	chunks[cx] = {}
	for cz = -1, 1 do
		chunks[cx][cz] = {}
		local block = Instance.new("Part", workspace)
		block.Size = Vector3.one * 4
		block.Anchored = true
		block.Position = WorldGeneration.BlockToWorldSpace(Vector3.new(cx, 0 ,cz), Vector3.zero)
		
		--createChunk(cx, cz)
	end
end


--print(chunk.Data, chunk.Position)
