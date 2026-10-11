local worldGen = game.ReplicatedStorage.WorldGen
local modules = game.ReplicatedStorage.Modules

local remotes = game.ReplicatedStorage.Remotes

local PartCache = require(modules.PartCache)
local Encode = require(modules.Encode)

local Chunk = require(worldGen.Chunk)
local BlockEnum = require(worldGen.BlockEnum)
local Config = require(worldGen.Config)
local Util = require(worldGen.Util)
local GlobalChunkGrid = require(game.ServerStorage.GlobalChunkGrid)

local SEED = 1239426969

local ERROSION_PTS = {
	{-1, 200},
	{-.8, 150},
	{-.6, 120},
	{-.4, 130},
	{0, 22.5},
	{.3, 15},
	{.4, 15},
	{.45, 55},
	{.7, 55},
	{.8, 15},
	{1, 5},
}

local CONTINENTAL_PTS = {
	{-1, 150},
	{-.8,10},
	{-.2,10},
	{0, 50},
	{.2, 50},
	{.3, 100},
	{.35, 100},
	{.45, 110},
	{.6, 130},
	{1, 140},
}

--local SURFACE_PTS = {
--	{-GRID_SIZE*4,1},
--	{-GRID_SIZE/2,0},
--	--{0,0},
--	{GRID_SIZE/2,0},
--	{GRID_SIZE*4,-1},
--}

--local SURFACE_PTS = {
--	{-1,0},
--	{-.8,10},
--	{-.1,40},
--	{.2,40},
--	{.5,50},
--	{.8,55},
--	{1,60}
--}

local TUNNEL_PTS = {
	
}

local TEMPERATURE_PTS = {
	{-1, }
}

function interpolate(x,pt1,pt2)
	return pt1.Y + (x - pt1.X)*(pt2.Y - pt1.Y)/(pt2.X - pt1.X)
end

function getBoundedReg(list,x)
	for i,v in pairs(list) do
		if v[1] >= x then
			return Vector2.new(table.unpack(list[i-1])), Vector2.new(table.unpack(v))
		end
	end
end

function getBoundedRegion(list,x)
	for i,v in pairs(list) do
		if v[1] >= x and v[2] < x then
			return v[3] or true
		end
	end
end

local function gridToMap(noise)
	return math.floor(noise/Config.BlockSize)*Config.BlockSize
end

function perlin3D(x: number, y: number, z: number, seed: number): number
	local AB = math.noise(x,y,seed)
	local BC = math.noise(y,z,seed)
	local AC = math.noise(x,z,seed)
	
	local BC = math.noise(y,x,seed)
	local CB = math.noise(z,y,seed)
	local CA = math.noise(z,x,seed)
	
	local ABC = AB + BC + AC + BC + CB + CA
	return ABC/6
end

function temperatureMap(x: number, z: number): number
	local FREQUENCY = 1000
	local noise = math.noise(x/FREQUENCY,z/FREQUENCY,SEED)
	--print(noise)
	
	if noise < -.25 then
		return "Snow"
	--elseif noise >= -.3 and noise < -.25 then
	--	return "Blue"
	elseif noise >= -.25 and noise < .1 then
		return "Plains"
	elseif noise >= .1 and noise < .7 then
		return "Desert"
	elseif noise >= .7  then
		return "Red"
	
	end
end

function surfaceMap(x: number, z: number): number
	--local octave = 3
	--local noise = 0
	--local freq
	
	--for i = 1, octave do
	--	noise += math.noise()
	--end
	
	local startAmp = 20
	local start
	
	local noise1 = math.noise(x/100.69,z/100.69,SEED)*startAmp
	local noise2 = math.noise(x/50.69,z/50.69,SEED)*startAmp/2
	local noise3 = math.noise(x/25.69,z/25.69,SEED)*startAmp/4
	
	return noise1+noise2+noise3
end

--function surfaceMap(x: number, y: number, z: number): number
--	local FREQUENCY = 180.69
--	local noise = perlin3D(x/FREQUENCY,y/FREQUENCY,z/FREQUENCY,SEED)
--	--print(noise,noise/10,noise*10)
--	--if y > 0 then
--	--	noise /= 10
--	--else
--	--	noise *= 10
--	--end
--	-- >0 is filled
--	-- <=0 is air
--	local UB, LB = getBoundedReg(SURFACE_PTS,noise)
--	return interpolate(noise,UB,LB)>0
--end

function continentalMap(x: number, z: number): number
	local FREQUENCY = 400.69
	local noise = math.noise(x/FREQUENCY,z/FREQUENCY,SEED)
	local UB, LB = getBoundedReg(CONTINENTAL_PTS,noise)
	return interpolate(noise,UB,LB)
end

function erosionsMap(x: number, z: number): number
	local FREQUENCY = 400.69
	local noise = math.noise(x/FREQUENCY,z/FREQUENCY,SEED)
	local UB, LB = getBoundedReg(ERROSION_PTS,noise)
	return interpolate(noise,UB,LB)
end

function caveFilter(x: number, y: number, z: number): number
	local freq = 150
	local density = math.abs(perlin3D(x/freq,y/freq,z/freq,SEED))
	local OB = .28
	local IB = OB-.03
	
	--if true then return false end
	
	-- -OB<x<OB intersect -IB<x<IB
	return density > OB
end

function caveMap(x: number, y: number, z: number): number
	local freq = 50
	local density = perlin3D(x/freq,y/freq,z/freq,SEED)
	local middle = .8
	local diff = .05
	local LB = middle-diff
	local UB = middle+diff
	
	return density < 0
end

function depthMap(depth)
	if depth < 5 then
		return 2
	elseif depth >= 5 and depth < 12 then
		return "Rock"
	elseif depth >= 12 then
		return "Slate"
	end
end

local function draw(x: number, y: number, z: number)
	local part = Instance.new("Part",workspace)
	part.Anchored = true
	part.Size = Vector3.new(Config.BlockSize,Config.BlockSize,Config.BlockSize)
	part.Position = Vector3.new(x,y,z)
	if y >= 180 then
		part.Color = Color3.fromRGB(255,255,255)
	elseif y <= 98 then
		part.Color = Color3.fromRGB(50, 168, 82)
	else
		part.Color = Color3.fromRGB(19, 64, 31)
	end
end

function getSurfaceHeight(x,z)
	return gridToMap(erosionsMap(x, z)+continentalMap(x,z)+surfaceMap(x,z))
end

function generateGloalChunkTable(cx,cz)
	if not GlobalChunkGrid[cx] then
		GlobalChunkGrid[cx] = {}
	end
	if not GlobalChunkGrid[cx][cz] then
		GlobalChunkGrid[cx][cz] = {
			Grid = {},
			Structures = {},
			Air = {},
			Hull = {},
		}
	end
	return GlobalChunkGrid[cx][cz]
end

function generateBlock(cx,cz,position)
	local chunk = generateGloalChunkTable(cx,cz)
	local data = chunk.Grid
	local x,y,z = table.unpack(position)
	if not data[x] then
		data[x] = {}
	end
	if not data[x][z] then
		data[x][z] = {}
	end
	
	if data[x][z][y] then
		return data[x][z][y]
	end
	
	local blockX = (cx-Config.ChunkSize/2)+(x-Config.ChunkSize/2)*4
	local blockZ = (cz-Config.ChunkSize/2)+(z-Config.ChunkSize/2)*4
	
	local terrainHeight = data[x][z]["Terrain"]
	local biome = data[x][z]["Biome"]
	if not terrainHeight then
		terrainHeight = getSurfaceHeight(blockX,blockZ)
		biome = temperatureMap(blockX,blockZ)
		data[x][z]["Terrain"] = terrainHeight
		data[x][z]["Biome"] = biome
		data[x][z][terrainHeight] = BlockEnum[Config.BiomeMap[biome][1]]
	end
	
	if not y then
		y = terrainHeight
	end
	
	if caveFilter(blockX,y,blockZ) then
		data[x][z][y] =  0
		table.insert(chunk.Air,{x,y,z})
	else
		if y < terrainHeight then
			local heightDiff = (data[x][z]["Terrain"]-y)/4
			local depth = depthMap(heightDiff)
			local block = Config.BiomeMap[biome][depth]
			local block = BlockEnum[block or depth]
			data[x][z][y] =  block
		end
		if not data[x][z]["Surface"] then
			data[x][z]["Surface"] = y
		end
	end
	
	return data[x][z][y], y
end

local function overflowCheck(cx,cz,x,z)
	local xOver = 0
	local zOver = 0
	if x > Config.ChunkSize then
		xOver = Config.BlockSize^3
		x = 1
	elseif x < 1 then
		xOver = -Config.BlockSize^3
		x = Config.ChunkSize
	end
	if z > Config.ChunkSize then
		zOver = Config.BlockSize^3
		z = 1
	elseif z < 1 then
		zOver = -Config.BlockSize^3
		z = Config.ChunkSize
	end

	return cx+xOver, cz+zOver, x, z
end

function getSurroundingPositions(cx,cz,position)
	local x,y,z = table.unpack(position)
	
	local adjacents = {
		{x-1,z},{x+1,z},{x,z-1},{x,z+1}
	}
	for i, pos in pairs(adjacents) do
		local cx1, cz1, x1, z1 = overflowCheck(cx,cz,table.unpack(pos))
		adjacents[i] = {
			--Chunk = {X = cx1, Z = cz1},
			--Block = {X = x1, Z = z1},
			cx1,cz1,x1,z1
		}
	end
	return adjacents
end

function getCaveEdges(cx,cz,stack)
	local visited = {}
	local edges = {}
	
	local function isVisited(x,y,z)
		if not visited[x] then
			visited[x] = {}
		end
		if not visited[x][y] then
			visited[x][y] = {}
		end
		if visited[x][y][z] then 
			return true	
		end
	end
	
	local function insert(x,y,z)
		if y < -64 then
			return
		end
		if isVisited(x,y,z) then
			return
		end
		table.insert(stack,{x,y,z})
	end
	
	for _, pt in pairs(stack) do
		local x, y, z = table.unpack(pt)
		if isVisited(x,y,z) then continue end
		local block = generateBlock(cx,cz,{x,y,z})
		if block then
			if block ~= 0 then
				table.insert(edges,{x,y,z,block})
			else
				for _, adjacent in pairs(getSurroundingPositions(cx,cz,{x,y,z})) do
					local cx1,cz1,x1,z1 = table.unpack(adjacent)
					if cx==cx1 and cz==cz1 then
						insert(x1,y,z1)
					else
						local globalChunk = generateGloalChunkTable(cx1,cz1)
						table.insert(globalChunk.Air, {x1,y,z1})
					end
				end
				insert(x,y-4,z)
				insert(x,y+4,z)
			end
		end
		visited[x][y][z] = true
	end
	return edges
end

function getCavityEdges(chunks, stack)
	local visited = {}
	local edges = {}
	
	--for _, position in pairs(chunks) do
	--	local cx, cz = table.unpack(position)
	--	visited[cx] = {}
	--	visited[cx][cz] = {}
	--end

	local function isVisited(cx,cz,x,y,z)
		if not visited[cx] then
			visited[cx] = {}
		end
		if not visited[cx][cz] then
			visited[cx][cz] = {}
		end
		local chunk = visited[cx][cz]
		if not chunk[x] then
			chunk[x] = {}
		end
		if not chunk[x][y] then
			chunk[x][y] = {}
		end
		if chunk[x][y][z] then 
			return true	
		end
	end

	local function insert(cx,cz,x,y,z)
		print(cx,cz,x,y,z)
		if y < -64 then
			return
		end
		if isVisited(cx,cz,x,y,z) then
			return
		end
		table.insert(stack,{cx,cz,x,y,z})
	end
	
	for _, pt in pairs(stack) do
		local cx, cz, x, y, z = table.unpack(pt)
		if isVisited(cx,cz,x,y,z) then continue end
		local block = generateBlock(cx,cz,{x,y,z})
		if block then
			if block ~= 0 then
				table.insert(edges,{cx,cz,x,y,z,block})
			else
				for _, adjacent in pairs(getSurroundingPositions(cx,cz,{x,y,z})) do
					local cx1,cz1,x1,z1 = table.unpack(adjacent)
					if visited[cx1] and visited[cx1][cz1] then
						insert(cx1,cz1,x1,y,z1)
					end
				end
				insert(x,y-4,z)
				insert(x,y+4,z)
			end
		end
		visited[cx][cz][x][y][z] = true
	end
	return edges
end

function testGenerateChunk3(cx,cz)
	local globalChunk = generateGloalChunkTable(cx,cz)
	if globalChunk["Generated"] then
		return globalChunk.Hull
	end
	
	local chunk = {}
	local air = {}
	
	local function updateConvexHull(x,y,z,block)
		local globalChunkHull = globalChunk.Hull
		if not globalChunkHull[x] then
			globalChunkHull[x] = {}
		end
		if not globalChunkHull[x][z] then
			globalChunkHull[x][z] = {}
		end
		globalChunkHull[x][z][y] = block
	end
	
	local function insert(x,y,z,block)
		chunk[x][z][y] = block
		updateConvexHull(x,y,z,block)
	end

	local function fillBelow(x,z,surfaceHeight)
		local adjacents = getSurroundingPositions(cx,cz,{x,nil,z})
		
		local min = {512}
		for i, adjacent in pairs(adjacents) do
			local cx1, cz1, x1, z1 = table.unpack(adjacent)
			local adjacentBlock, adjacentHeight = generateBlock(cx1,cz1,{x1,nil,z1})
			adjacent[5] = adjacentHeight

			if adjacentHeight < min[1] then
				min = {adjacentHeight, adjacent}
			end
		end
		
		for y = min[1]+4, surfaceHeight-4, 4 do
			local toFill = false
			for _, adjacent in pairs(adjacents) do
				local cx1, cz1, x1, z1 = table.unpack(adjacent)
				local block = generateBlock(cx1,cz1,{x1,y,z1})
				
				if block and block ~= 0 then
					adjacent[6] = true --column is not empty
				else
					toFill = true
				end
			end
			if toFill then
				local block = generateBlock(cx,cz,{x,y,z})
				if block ~= 0 then
					insert(x,y,z,block)
				end
			end
		end

	end

	for x = 1, Config.ChunkSize do
		chunk[x] = {}
		for z = 1, Config.ChunkSize do
			chunk[x][z] = {}
			local surfaceBlock, surfaceHeight = generateBlock(cx,cz,{x,nil,z})
			if surfaceBlock == 0 then 
				table.insert(air,{x,surfaceHeight,z})
				continue 
			end
			insert(x,surfaceHeight,z,surfaceBlock)
			fillBelow(x,z,surfaceHeight)
		end
	end
	
	for _, pt in pairs(GlobalChunkGrid[cx][cz].Air) do
		table.insert(air,pt)
	end
	
	for _, pt in pairs(getCaveEdges(cx,cz,air)) do
		local x, y, z, block = table.unpack(pt)
		insert(x,y,z,block)
	end
	--globalChunk["Generated"] = true
	return chunk
end

remotes.GetChunk.OnServerEvent:Connect(function(player, grid)
	--grid = Encode.decompress(grid)
	--local chunkPositions = {}
	--local chunks = {}
	--local final = {}
	--for _, data in pairs(grid) do
	--	--task.desynchronize()
	--	local cx, cz = Util.ChunkToBlockGrid(data[1]), Util.ChunkToBlockGrid(data[2])
	--	table.insert(chunkPositions,{cx,cz})
	--	if not chunks[cx] then
	--		chunks[cx] = {}
	--	end
	--	if not chunks[cx][cz] then
	--		chunks[cx][cz] = {}
	--	end
	--	chunks[cx][cz] = testGenerateChunk3(cx,cz)
	--	--task.synchronize()
	--end
	--local air = {}
	--for _, chunk in pairs(chunkPositions) do
	--	local cx, cz = table.unpack(chunk)
	--	for _, pt in pairs(GlobalChunkGrid[cx][cz].Air) do
	--		--print(pt)
	--		table.insert(air,{cx,cz,table.unpack(pt)})
	--	end
	--end
	--for _, data in pairs(getCavityEdges(chunkPositions,air)) do
	--	local cx,cz,x,y,z,block = table.unpack(data)
	--	chunks[cx][cz][x][z][y] = block
	--end
	--for row, _ in pairs(chunks) do
	--	for col, chunk in pairs(_) do
	--		table.insert(final,{row,col,chunk})
	--	end
	--end
	for _, data in pairs(grid) do
		--task.desynchronize()
		local cx, cz = Util.ChunkToBlockGrid(data[1]), Util.ChunkToBlockGrid(data[2])
		data[3] = testGenerateChunk3(cx,cz)
		--task.synchronize()
	end
	task.synchronize()
	--grid = Encode.compress(grid)
	remotes.GetChunk:FireClient(player, grid)
end)
