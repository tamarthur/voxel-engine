local HttpService = game:GetService("HttpService")

local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local GenerationService = require(game.ServerStorage.Modules.GenerationService)
local Tensor = require(game.ReplicatedStorage.Modules.Utility.Tensor)

local GridService = {}

local SurfaceGrid = {}
local Structures = {}
local WorldGrid = setmetatable({}, {
	__index = function(self, key)
		local value = rawget(self, key)
		if not value then
			local grid = Tensor.new(3)
			--for y = 1, WorldConfig.CHUNK_SIZE do
			--	grid[y] = {}
			--	for z = 1, WorldConfig.CHUNK_SIZE do
			--		grid[y][z] = {}
			--		for x = 1, WorldConfig.CHUNK_SIZE do
			--			grid[y][z][x] = 0
			--		end
			--	end
			--end
			self[key] = GenerationService:GenerateChunk(key, grid)
			return rawget(self, key)
		end
		return value
	end
})

local function GetAdjacentBlocks(blockIndex, chunkPosition, callback)
	local blockPosition = WorldBuilder:BlockIndexToBlockPosition(blockIndex, chunkPosition)
	for _, dir in pairs(WorldConfig.DIRECTION_MAP) do
		callback(WorldBuilder:BlockPositionToBlockIndex(blockPosition + dir))
	end
end

function GridService:GetBlock(cx, cy, cz, x, y, z)
	local chunkKey = cx.." "..cy.." "..cz
	return WorldGrid[chunkKey][y][z][x]--WorldGrid[chunkKey]:Get(y, z, x)
end

function GridService:AddBlock(cx, cy, cz, x, y, z, blockID)
	if blockID <= 1 then return end
	
	local chunkKey = cx.." "..cy.." "..cz
	local blockData = WorldGrid[chunkKey]:Get(y, z, x)--WorldGrid[chunkKey][y][z][x]
	if blockData and blockData ~= 1 then return end
	
	local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
	local generatedBlock = GenerationService:GenerateBlock(WorldBuilder:GetComponents(blockPosition))
	--if generatedBlock and generatedBlock ~= 1 then
	--	WorldGrid[chunkKey][y][z][x] = generatedBlock
	--	return
	--end
	print(blockID)
	WorldGrid[chunkKey]:Set(y, z, x, blockID)--WorldGrid[chunkKey][y][z][x] = blockID
	
	for _, dir in pairs(WorldConfig.DIRECTION_MAP) do
		local adjacentPosition = blockPosition + dir
		local blockIndex, chunkPosition = WorldBuilder:BlockPositionToBlockIndex(adjacentPosition)

		local chunk = WorldGrid[WorldBuilder:CoordinatesToKey(WorldBuilder:GetComponents(chunkPosition))]
		local block = chunk:Get(blockIndex.Y, blockIndex.Z, blockIndex.X)--chunk[blockIndex.Y][blockIndex.Z][blockIndex.X]
		if block and block ~= 0 then
			continue
		end

		chunk:Set(blockIndex.Y, blockIndex.Z, blockIndex.X, 1)--chunk[blockIndex.Y][blockIndex.Z][blockIndex.X] = 1
	end
	
	return true
end

function GridService:RemoveBlock(cx, cy, cz, x, y, z)
	local chunkKey = cx.." "..cy.." "..cz
	local blockData = WorldGrid[chunkKey]:Get(y, z, x)--WorldGrid[chunkKey][y][z][x]
	print(blockData)
	if not blockData or blockData == 1 then return end
	WorldGrid[chunkKey]:Set(y, z, x, 1)--WorldGrid[chunkKey][y][z][x] = 1
	
	local updatedBlocks = {}
	local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
	for _, dir in pairs(WorldConfig.DIRECTION_MAP) do
		local adjacentPosition = blockPosition + dir
		local blockIndex, chunkPosition = WorldBuilder:BlockPositionToBlockIndex(adjacentPosition)
		--print(blockIndex)
		
		local chunk = WorldGrid[WorldBuilder:CoordinatesToKey(WorldBuilder:GetComponents(chunkPosition))]
		local block = chunk:Get(blockIndex.Y, blockIndex.Z, blockIndex.X)--chunk[blockIndex.Y][blockIndex.Z][blockIndex.X]
		if block and block ~= 0 then
			continue
		end

		local generatedBlock = GenerationService:GenerateBlock(WorldBuilder:GetComponents(adjacentPosition))
		chunk:Set(blockIndex.Y, blockIndex.Z, blockIndex.X, generatedBlock)--chunk[blockIndex.Y][blockIndex.Z][blockIndex.X] = generatedBlock
		table.insert(updatedBlocks, {chunkPosition.X, chunkPosition.Y, chunkPosition.Z, blockIndex.X, blockIndex.Y, blockIndex.Z, generatedBlock})
	end

	table.insert(updatedBlocks, {cx, cy, cz, x, y, z})
	return updatedBlocks
end

function GridService:GetChunks(requestData)
	local chunks = {}
	for _, key in pairs(requestData) do
		local chunkData = WorldGrid[key]
		local serialized  = {}
		
		chunkData:Iterate(function(y, z, x, blockID)
			if blockID == 1 then return end
			table.insert(serialized, {x, y, z, blockID})
		end)
		
		--for y, _ in pairs(chunkData) do
		--	for z, _ in pairs(_) do
		--		for x, blockID in pairs(_) do
		--			if blockID == 1 then continue end
		--			table.insert(serialized, {x, y, z, blockID})
		--		end
		--	end
		--end
		--chunks[key] = chunkData
		table.insert(chunks, {key, serialized})
	end
	return chunks
end

function GridService:_debugChunk(chunkKey)
	--print(HttpService:JSONEncode(WorldGrid[chunkKey]))
	return WorldGrid[chunkKey]
end

return GridService

--local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
--print(WorldBuilder:BlockPositionToBlockIndex(Vector3.new(8,8,8), Vector3.zero))
