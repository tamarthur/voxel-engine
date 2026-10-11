local HttpService = game:GetService("HttpService")

local TerrainModules = game.ServerStorage.Modules.Terrain
local Modules = game.ReplicatedStorage.Modules
local Storage = game.ReplicatedStorage.Storage

local base93 = require(Modules.Util.base93)
local Signal = require(Modules.Util.Signal)

local FractalNoise = require(TerrainModules.FractalNoise)
local FractalNoise3D = require(TerrainModules.FractalNoise3D)

local BlockEnum = require(Modules.Terrain.BlockEnum)
local WorldConfig = require(Modules.Terrain.WorldConfig)
local WorldUtil = require(Modules.Terrain.WorldUtil)
local WorldGrid = require(Storage.WorldGrid)

local WorldGenerator = {}

local function noise3d(x, y, z, seed)
	local ab = math.noise(x, y, seed)
	local bc = math.noise(y, z, seed)
	local ac = math.noise(x, z, seed)
	local ba = math.noise(y, x, seed)
	local cb = math.noise(z, y, seed)
	local ca = math.noise(z, x, seed)
	return math.clamp((ab + bc + ac + ba + cb + ca)/6, -1, 1)
end

function WorldGenerator.GenerateCaves(wx, wy, wz)
	--local noise = noise3d(wx/80, wy/80, wz/80, WorldGenerator.Seed)
	return math.abs(WorldGenerator.CaveNoise:GetNoise(wx, wy, wz)) < .2
end

function WorldGenerator.GenerateBiome(cx, cy, cz, x, y, z)
	
end

function WorldGenerator.GenerateSurfaceLayer(cx, cz)
	local surface = {}
	for cy = WorldConfig.WORLD_ALTITUDE, 0, -1 do
		local data = WorldGrid[cx.." "..cy.." "..cz].Data
		

		for x = 1, WorldConfig.CHUNK_SIZE do
			for z = 1, WorldConfig.CHUNK_SIZE do
				if surface[x.." "..z] then continue end
				for y = WorldConfig.CHUNK_SIZE, 1, -1 do
					if not data[x][z][y] then continue end
					
					data[x][z][y] = BlockEnum.fromName["Grass"].ID
					surface[x.." "..z] = true
					
					break
				end
			end
		end	
		

	end
end

function WorldGenerator.GenerateTerrainHeight(x, z)
	
end

function WorldGenerator.GenerateTerrainDetail(wx, wy, wz, offset)
	local maxHeight = (WorldConfig.WORLD_ALTITUDE+.5) * WorldConfig.CHUNK_SIZE * WorldConfig.BLOCK_SIZE - WorldConfig.BLOCK_SIZE/2
	local squashingFactor = 1
	local midPoint = maxHeight/2 + (offset or 0)
	
	local heightBias = wy/(midPoint) - 1
	local noise = WorldGenerator.SurfaceNoise:GetNoise(wx, wy, wz)
	
	return noise + squashingFactor * heightBias < 0
end

function WorldGenerator.ReplaceStack()
	
end

function WorldGenerator.GetSurface(cx, cy, cz)
	
end

function WorldGenerator.GenerateColumn(cx, cz)
	local surface = {}
	for cy = WorldConfig.WORLD_ALTITUDE, 0, -1 do
		local data = {}
		
		for x = 1, WorldConfig.CHUNK_SIZE do
			data[x] = {}
			for z = 1, WorldConfig.CHUNK_SIZE do
				data[x][z] = {}
				
				for y = WorldConfig.CHUNK_SIZE, 1, -1 do
					local wx, wy, wz = WorldUtil.getWorldPosition(cx, cy, cz, x, y, z)
					
					--Bottom of the world
					if wy == 2 then
						data[x][z][y] = BlockEnum.fromName["Bedrock"].ID
						continue
					end
					
					--Cap off the world
					if wy < 0 then break end
					
					if not WorldGenerator.GenerateTerrainDetail(wx, wy, wz) then 
						continue
					end
					
					local replaceBlock
					if not surface[x.." "..z] then
						surface[x.." "..z] = wy
						replaceBlock = BlockEnum.fromName["Grass"].ID
						
					else
						if surface[x.." "..z] - wy < 3 * WorldConfig.BLOCK_SIZE then
							replaceBlock = BlockEnum.fromName["Dirt"].ID
						end
					end
					
					if not WorldGenerator.GenerateCaves(wx, wy, wz) then 
						continue
					end 
					
					data[x][z][y] = replaceBlock or BlockEnum.fromName["Stone"].ID
				end
				
			end
		end	
		
		local chunk = {Data = data, Hull = {}}
		if next(surface) then
			chunk.Surface = surface
		end
		WorldGrid[cx.." "..cy.." "..cz] = chunk
	end
	--return {Data = data, Hull = {}}
end

function WorldGenerator.GenerateHull(cx, cy, cz)
	local halfWorldSize = math.floor(WorldConfig.WORLD_SIZE/2)
	local directions = {{1,0,0}, {0,1,0}, {0,0,1}, {-1,0,0}, {0,-1,0}, {0,0,-1}}
	
	--local group = Instance.new("Model", workspace)
	--group.Name = cx.." "..cy.." "..cz
	local chunk = WorldGrid[cx.." "..cy.." "..cz]
	
	for x = 1, WorldConfig.CHUNK_SIZE do
		for z = 1, WorldConfig.CHUNK_SIZE do
			for y = 1, WorldConfig.CHUNK_SIZE do
				
				if not chunk.Data[x][z][y] then continue end
				
				for _, pt in ipairs(directions) do
					local px, py, pz = table.unpack(pt)
					local ax, ay, az, x1, y1, z1, sameChunk = WorldUtil.boundCell(cx, cy, cz, x+px, y+py, z+pz)
					
					--Out of bounds
					if ay < 0 or ay > WorldConfig.WORLD_ALTITUDE or 
						math.abs(ax) > halfWorldSize or 
						math.abs(az) > halfWorldSize then
						continue
					end
					
					--Don't render bottom of the world
					if cy == 0 and y < 10 and py == -1 then continue end
					
					local adjacentBlock
					if sameChunk then
						adjacentBlock = chunk.Data[x1][z1][y1]
					else
						adjacentBlock = WorldGrid[ax.." "..ay.." "..az].Data[x1][z1][y1]
					end
					
					if not adjacentBlock then
						chunk.Hull[x.." "..y.." "..z] = chunk.Data[x][z][y]
						
						--local wx, wy, wz = WorldUtil.getWorldPosition(cx, cy, cz, x, y, z)
						--local part = Instance.new("Part",group)
						--part.Anchored = true
						--part.Size = WorldConfig.BLOCK_SIZE*Vector3.one
						--part.Position = Vector3.new(wx, wy, wz)
						--part.Name = x.." "..y.." "..z
						break
					end
					
				end
				
			end
		end
	end
end

function WorldGenerator.Start()
	local timer = tick()
	local halfWorldSize = math.floor(WorldConfig.WORLD_SIZE/2)
	local totalIterations = WorldConfig.WORLD_SIZE + WorldConfig.WORLD_SIZE
	
	local debugCount = 0
	for cx = halfWorldSize, -halfWorldSize, -1 do
		for cz = halfWorldSize, -halfWorldSize, -1 do
			WorldGenerator.GenerateColumn(cx, cz)
		end
		debugCount += 1
		game.ReplicatedStorage.LoadPercent.Value = debugCount / totalIterations
		task.wait()
	end
	
	for cx = halfWorldSize, -halfWorldSize, -1 do
		for cy = 0, WorldConfig.WORLD_ALTITUDE do
			for cz = halfWorldSize, -halfWorldSize, -1 do
				WorldGenerator.GenerateHull(cx, cy, cz)
			end
		end
		debugCount += 1
		game.ReplicatedStorage.LoadPercent.Value = debugCount / totalIterations
		task.wait()
	end

	--for cx = halfWorldSize, -halfWorldSize, -1 do
	--	for cy = 0, WorldConfig.WORLD_ALTITUDE do
	--		for cz = halfWorldSize, -halfWorldSize, -1 do
	--			local key = cx.." "..cy.." "..cz
	--			WorldGrid[key] = {
	--				Data = base93.compress(HttpService:JSONEncode(WorldGrid[key].Data)),
	--				Hull = base93.compress(HttpService:JSONEncode(WorldGrid[key].Hull))
	--			} 
	--			task.wait()
	--		end
	--	end
	--end
	--print((WorldConfig.WORLD_ALTITUDE+.5) * WorldConfig.CHUNK_SIZE * (WorldConfig.BLOCK_SIZE-.5))
	--print(WorldGrid)
	WorldGenerator.Loaded:Fire()
	print("Time took to generate: "..(tick()-timer))
end

function WorldGenerator.Init()
	WorldGenerator.Seed = 12434--math.random(1, 1e9)
	WorldGenerator.SurfaceNoise = FractalNoise3D.new(WorldGenerator.Seed,256,2,3,.25)
	WorldGenerator.CaveNoise = FractalNoise3D.new(WorldGenerator.Seed,160,3,3,.25)
	WorldGenerator.SurfaceBiomeNoise = FractalNoise.new(WorldGenerator.Seed,160,3,3,.25)
	
	WorldGenerator.Loaded = Signal.new()
end

return WorldGenerator
