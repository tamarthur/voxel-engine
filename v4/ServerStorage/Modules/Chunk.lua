--!strict
local WorldGeneration = require(script.Parent.WorldGeneration)
local WorldConfig = require(script.Parent.WorldConfig)
local BLOCK_SIZE = WorldConfig.BLOCK_SIZE
local CHUNK_SIZE = WorldConfig.CHUNK_SIZE

local types = require(script.Parent.Types)
export type ChunkInstance = types.ChunkInstance

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new(x: number, y: number, z: number) : ChunkInstance
	
	local self: ChunkInstance = setmetatable({
		Data = table.create(CHUNK_SIZE^3, 0),
		Position = Vector3.new(x, y, z),
	}, Chunk)
	
	return self
end

function Chunk._createBlock(self: ChunkInstance): Part
	local block = Instance.new("Part", workspace)
	block.Size = Vector3.one * BLOCK_SIZE
	block.Anchored = true
	
	return block
end

function Chunk._toIndex(self: ChunkInstance, x: number, y: number, z: number): number
	-- f: [1,16]^3 -> [1, 16^3]
	return x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE
end

function Chunk.Iterate(self: ChunkInstance, callback: (x: number, y: number, z: number) -> ())
	for x = 1, CHUNK_SIZE do
		for y = 1, CHUNK_SIZE do
			for z = 1, CHUNK_SIZE do
				callback(x, y, z)
			end
		end
	end
end

function Chunk.Set(self: ChunkInstance, x: number, y: number, z: number, id: number)
	self.Data[self:_toIndex(x, y, z)] = id
end

function Chunk.Get(self: ChunkInstance, x: number, y: number, z: number): number
	return self.Data[self:_toIndex(x, y, z)]
end

function Chunk.Load(self: ChunkInstance)
	
	local convexHull = {}
	
	
	local quads = {self.Data[self:_toIndex(1, 1, 1)]}
	for x = 2, CHUNK_SIZE do
		
		--for y = 1, CHUNK_SIZE do
			
		--end
	end

	self:Iterate(function(x: number, y: number, z: number)
		--print(self:Get(x, y, z))
		if self:Get(x, y, z) == 0 then
			return
		end
		local block = self:_createBlock()
		
		block.Position = WorldGeneration.BlockToWorldSpace(self.Position, Vector3.new(x, y, z))
	end)
end

function Chunk.GetWorldBounds(self: ChunkInstance)
	return CHUNK_SIZE * self.Position 
end

return Chunk
