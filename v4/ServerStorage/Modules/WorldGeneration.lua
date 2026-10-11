--!strict

local WorldConfig = require(script.Parent.WorldConfig)
local BLOCK_SIZE = WorldConfig.BLOCK_SIZE
local CHUNK_SIZE = WorldConfig.CHUNK_SIZE


local WorldGeneration = {}

function WorldGeneration.PointwiseOperation(vec: Vector3, map: (number) -> number): Vector3
	return Vector3.new(map(vec.X), map(vec.Y), map(vec.Z))
end

function WorldGeneration.WorldToChunkSpace(WorldPosition: Vector3): (Vector3, Vector3)
	local ChunkPosition = WorldGeneration.Discretize(.5/(BLOCK_SIZE*CHUNK_SIZE) * WorldPosition)
	local BlockIndex = WorldGeneration.PointwiseOperation(WorldPosition, function(a0: number): number 
		return a0 % CHUNK_SIZE 
	end)
	return ChunkPosition, BlockIndex
end

function WorldGeneration.ChunkToWorldSpace(ChunkPosition: Vector3): Vector3
	return BLOCK_SIZE * CHUNK_SIZE * ChunkPosition
end

function WorldGeneration.BlockToWorldSpace(ChunkPosition: Vector3, BlockIndex: Vector3): Vector3
	local WorldChunkPosition: Vector3 = WorldGeneration.ChunkToWorldSpace(ChunkPosition)
	local WorldOffset: Vector3 = WorldGeneration.ChunkToWorldSpace( .5 * Vector3.one )
	
	local BlockPosition: Vector3 = BLOCK_SIZE * BlockIndex
	local BlockOffset: Vector3 = BLOCK_SIZE/2 * Vector3.one

	return (WorldChunkPosition - WorldOffset) + (BlockPosition - BlockOffset)
end

function WorldGeneration.PlaneMap(x: number, y: number): number
	return 0
end

function WorldGeneration.SurfaceMap(x: number, y: number): number
	return 20*math.sin(x/20) 
		--+ math.cos(y/20)
end

function WorldGeneration.GetSurfaceRangeOnInterval(x1: number, x2: number, y1: number, y2: number): (number, number)
	return -20, 20
end

function WorldGeneration.Discretize(Position: Vector3): Vector3
	return WorldGeneration.PointwiseOperation(Position, math.floor)
end

return WorldGeneration
