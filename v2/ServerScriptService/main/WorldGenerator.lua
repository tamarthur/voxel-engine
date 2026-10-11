local HttpService = game:GetService("HttpService")

local TerrainModules = game.ServerStorage.Modules.Terrain
local Modules = game.ReplicatedStorage.Modules
local Storage = game.ReplicatedStorage.Storage

local BFS = require(Modules.Util.BFS)
local base93 = require(Modules.Util.base93)
local Signal = require(Modules.Util.Signal)
local Workers = require(Modules.Util.WorkerThreads)

local FractalNoise = require(TerrainModules.FractalNoise)
local FractalNoise3D = require(TerrainModules.FractalNoise3D)

local BlockEnum = require(Modules.Terrain.BlockEnum)
local WorldConfig = require(Modules.Terrain.WorldConfig)
local WorldUtil = require(Modules.Terrain.WorldUtil)
local WorldGrid = require(Modules.Terrain.WorldGrid)
local WorldData = require(Modules.Terrain.WorldData)

local WorldGenerator = {}

function WorldGenerator.GenerateCaveValue(wx, wy, wz)
	--local noise = noise3d(wx/80, wy/80, wz/80, WorldGenerator.Seed)
	return math.abs(WorldGenerator.CaveNoise:GetNoise(wx, wy, wz))
end

function WorldGenerator.GenerateBaseTerrainElevation(wx, wz)
	--local maxHeight = (WorldConfig.WORLD_ALTITUDE+.5) * WorldConfig.CHUNK_SIZE * WorldConfig.BLOCK_SIZE - WorldConfig.BLOCK_SIZE/2
	return 0--2*wx--math.sin(wx/64)*64
end

function WorldGenerator.GenerateTerrainSurfaceValue(wx, wy, wz, squashingFactor)
	
	--if wy < WorldConfig.TERRAIN_DEPTH then
	--	return -1
	--end
	
	--if wy > WorldConfig.TERRAIN_HEIGHT then
	--	return 1
	--end

	--local heightBias = wy/(baseHeight) - 1
	
	local heightOffset = WorldGenerator.GenerateBaseTerrainElevation(wx, wz)
	
	squashingFactor = (not squashingFactor and .5) or squashingFactor
	
	local height = math.clamp(wy - heightOffset, -WorldConfig.TERRAIN_RANGE + .001, WorldConfig.TERRAIN_RANGE - .001)
	local heightBias = -height / (height^2 - WorldConfig.TERRAIN_RANGE^2 )
	
	local noise = WorldGenerator.SurfaceNoise:GetNoise(wx, wy, wz)

	return noise + heightBias * squashingFactor * WorldConfig.TERRAIN_RANGE
end

function WorldGenerator.IsBlockSolid(wx, wy, wz)
	
	if WorldGenerator.GenerateTerrainSurfaceValue(wx, wy, wz) > 0 then 
		return
	end
	
	if WorldGenerator.GenerateCaveValue(wx, wy, wz) > .2 then
		return
	end
	
	return true
end

function	 WorldGenerator.GenerateBlock(wx, wy, wz, surfaceValue)	
	local block = BlockEnum.fromName["Stone"].ID
	
	if math.abs(surfaceValue) < .05 then
		return BlockEnum.fromName["Grass"].ID
	end
	
	if math.abs(surfaceValue) < .1 then
		return BlockEnum.fromName["Dirt"].ID
	end

	return block
end

function WorldGenerator.GetBlock(cx, cy, cz, x, y, z)
	local wx, wy, wz = WorldUtil.getWorldPosition(cx, cy, cz, x, y, z)
	
	--if not WorldGenerator.IsBlockSolid(wx, wy, wz) then
	--	return
	--end
	
	local block = BlockEnum.fromName.Air
	
	local surfaceValue = WorldGenerator.GenerateTerrainSurfaceValue(wx, wy, wz)
	if surfaceValue > 0 then 
		WorldGrid[WorldUtil.coordinateToKey(cx, cy, cz)].Data[x][z][y] = block
		return
	end

	local caveValue = WorldGenerator.GenerateCaveValue(wx, wy, wz)
	if caveValue > .2 then
		WorldGrid[WorldUtil.coordinateToKey(cx, cy, cz)].Data[x][z][y] = block
		return
	end
	
	block = WorldGenerator.GenerateBlock(wx, wy, wz, surfaceValue)
	WorldGrid[WorldUtil.coordinateToKey(cx, cy, cz)].Data[x][z][y] = block
	
	return block, surfaceValue, caveValue
end

function WorldGenerator.IsBlockHull(cx, cy, cz, x, y, z)
	local normals = {
		{1,0,0}, 
		{0,1,0}, 
		{0,0,1}, 
		{-1,0,0}, 
		{0,-1,0}, 
		{0,0,-1},
	}
	for _, p in pairs(normals) do
		local cx1, cy1, cz1, x1, y1, z1, sameChunk = WorldUtil.boundCell(cx, cy, cz, x + p[1], y + p[2], z + p[3])
		
		local adjacent = WorldGenerator.GetBlock(cx1, cy1, cz1, x1, y1, z1)
		if not adjacent then return true end
	end
end

function WorldGenerator.GenerateHull(key)
	
	debug.profilebegin("Generating chunk")
	local chunk = WorldGrid[key]
	if chunk.Generated then return end
	
	local cx, cy, cz = WorldUtil.keyToCoordinate(key)

	local x, y, z = WorldUtil.getWorldPosition(cx, cy, cz, 1, math.floor(WorldConfig.CHUNK_SIZE/2), 1)
	
	if math.abs(y) > WorldConfig.TERRAIN_RANGE then
		chunk.Generated = true
		return 
	end
	
	--for x = 1, WorldConfig.CHUNK_SIZE do
	--	for z = 1, WorldConfig.CHUNK_SIZE do
			
	--		for y = 1, WorldConfig.CHUNK_SIZE do
	--			local block, surfaceValue, caveValue = WorldGenerator.GetBlock(cx, cy, cz, x, y, z)

	--			if not block then continue end
				
	--			local bx, bz = WorldUtil.getBlockNumber(cx, z), WorldUtil.getBlockNumber(cz, x)
	--			local key = WorldUtil.keyToCoordinate(bx, bz)

	--			WorldData.Surface[key] = y
	--			chunk.Hull[WorldUtil.coordinateToKey(x, y, z)] = block
	--			break
	--		end
			
	--		--local bx, bz = WorldUtil.getBlockNumber(cx, z), WorldUtil.getBlockNumber(cz, x)
	--		--local key = WorldUtil.keyToCoordinate(bx, bz)

	--		--if WorldData.Surface[key] then
	--		--	chunk.Hull[WorldUtil.coordinateToKey(x, y, z)] = block
	--		--	return
	--		--end
			
			
	--		--local block, surfaceValue, caveValue = WorldGenerator.GetBlock(cx, cy, cz, x, y, z)

	--		--if not block then return end

	--		--local bx, bz = WorldUtil.getBlockNumber(cx, z), WorldUtil.getBlockNumber(cz, x)
	--		--local key = WorldUtil.keyToCoordinate(bx, bz)

	--		--if WorldData.Surface[key] then
	--		--	return
	--		--end

	--		--WorldData.Surface[key] = y

	--		--chunk.Hull[WorldUtil.coordinateToKey(x, y, z)] = block
	--	end
	--end
	
	local firstBlock
	WorldUtil.loopThroughChunk(function(x, y, z)
		local block, surfaceValue, caveValue = WorldGenerator.GetBlock(cx, cy, cz, x, y, z)
		
		if not block then return end
			
		--local bx, bz = WorldUtil.getBlockNumber(cx, z), WorldUtil.getBlockNumber(cz, x)
		--local key = WorldUtil.keyToCoordinate(bx, bz)
		
		--if WorldData.Surface[key] then
		--	return
		--end
		
		--WorldData.Surface[key] = true
		
		
		local isSurface = math.abs(surfaceValue) < .08 
		--local isCaveEdge = caveValue > .18
		
		if isSurface then
			chunk.Hull[WorldUtil.coordinateToKey(x, y, z)] = block
		end

	end)
	
	chunk.Generated = true
	--print(WorldGrid[key])
	debug.profileend()
	task.wait()
	return {}
end

function WorldGenerator.GenerateChunks(mx, my, mz, direction, requested)
	
	--local workers = Workers.New(script, "GenerateHull", 8)
	
	--WorldGenerator.GenerateHull(requested)
	
	for key, _ in pairs(requested) do
		--workers:DoWork(key)
		WorldGenerator.GenerateHull(key)
	end
	
	local chunks = {}
	for key, _ in pairs(requested) do
		local chunk = WorldGrid[key]
		chunks[key] = chunk.Hull
	end
	
	return chunks, {}
end


function WorldGenerator.Start()
	--Generate first chunk to base off hull
	--WorldGenerator.SetupChunk(cx, cy, cz, callback)
end

function WorldGenerator.Init()
	WorldGenerator.Seed = 75312434--math.random(1, 1e9)
	WorldGenerator.SurfaceNoise = FractalNoise3D.new(WorldGenerator.Seed,256,3,2,.2)
	WorldGenerator.CaveNoise = FractalNoise3D.new(WorldGenerator.Seed,160,3,3,.25)
	WorldGenerator.SurfaceBiomeNoise = FractalNoise.new(WorldGenerator.Seed,160,3,3,.25)
	
	WorldData.Surface = {}

	WorldGenerator.Loaded = Signal.new()
end

return WorldGenerator
