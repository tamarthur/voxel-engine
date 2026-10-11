local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local Builder = {}
--[[
BlockIndex = [1, 16]
BlockPosition = Each block unit on world 
StudPosition = Each block unit * 4

]]

function Builder:GetComponents(vector)
	return vector.X, vector.Y, vector.Z
end

function Builder:ComponentOperation(operation, vector)
	return Vector3.new(operation(vector.X), operation(vector.Y), operation(vector.Z))
end

function Builder:CoordinatesToKey(...)
	local args = {...}
	local key = args[1]
	for i = 2, #args - 1 do
		key = key.." "..args[i] 
	end
	key = key.." "..args[#args]
	return key
end

function Builder:KeyToCoordinates(key: string)
	return table.unpack(key:split(" "))
end

function Builder:RoundToNearestInteger(x: number)
	return math.floor(x + .5)
end

function Builder:MapNumberToGrid(x: number)
	return WorldConfig.BLOCK_SIZE*math.floor(x/WorldConfig.BLOCK_SIZE)
end

function Builder:MapPositionToGrid(position: Vector3)
	return WorldConfig.BLOCK_SIZE*(Builder:ComponentOperation(math.floor, position/WorldConfig.BLOCK_SIZE) + .5*Vector3.one)
end

function Builder:StudPositionToBlockPosition(position: Vector3)
	return (position) / WorldConfig.BLOCK_SIZE + .5*Vector3.one
end

function Builder:StudPositionToChunkPosition(position: Vector3)
	position = position / (WorldConfig.BLOCK_SIZE*WorldConfig.CHUNK_SIZE) + .5*Vector3.one
	return Builder:ComponentOperation(math.floor, position)
end

function Builder:StudPositionToBlockIndex(studPosition: Vector3, chunkPosition: Vector3)
	return Builder:StudPositionToBlockPosition(studPosition) + (WorldConfig.CHUNK_SIZE/2)*Vector3.one - WorldConfig.CHUNK_SIZE*chunkPosition
end

function Builder:BlockIndexToBlockPosition(indexPosition: Vector3, chunkPosition: Vector3)
	--index 1 = -7 position
	--index 16 = 8 position
	return indexPosition - (WorldConfig.CHUNK_SIZE/2)*Vector3.one + WorldConfig.CHUNK_SIZE*chunkPosition
end

function Builder:BlockIndexToStudPosition(indexPosition: Vector3, chunkPosition: Vector3)
	return Builder:BlockIndexToBlockPosition(indexPosition, chunkPosition) * WorldConfig.BLOCK_SIZE - (WorldConfig.BLOCK_SIZE/2)*Vector3.one
end

function Builder:BlockPositionToBlockIndex(blockPosition: Vector3)
	local overflowIndex = blockPosition + (WorldConfig.CHUNK_SIZE/2)*Vector3.one
	--local blockIndex = Builder:ComponentOperation(function(x) 
	--	if x == WorldConfig.CHUNK_SIZE + 1 then return 1 end
	--	if x == 0 then return WorldConfig.CHUNK_SIZE end
	--	return x
	--end, overflowIndex)
	
	--local chunkPosition = Builder:ComponentOperation(function(x) 
	--	return math.floor((x - 1)/WorldConfig.CHUNK_SIZE)
	--end, overflowIndex)
	
	local blockIndex = Builder:ComponentOperation(function(x) return ((x - 1) % WorldConfig.CHUNK_SIZE + WorldConfig.CHUNK_SIZE) % WorldConfig.CHUNK_SIZE + 1 end, overflowIndex)
	local chunkPosition = Builder:ComponentOperation(math.floor, (overflowIndex - Vector3.one) / WorldConfig.CHUNK_SIZE )

	return blockIndex, chunkPosition
end

function Builder:BlockPositionToStudPosition(indexPosition: Vector3, chunkPosition: Vector3)
	return (Builder:BlockIndexToBlockPosition(indexPosition, chunkPosition) - .5*Vector3.one) * WorldConfig.BLOCK_SIZE
end

function Builder:ChunkPositionToBlockPosition(position: Vector3)
	return position * WorldConfig.CHUNK_SIZE
end

function Builder:ChunkPositionToStudPosition(position: Vector3)
	return WorldConfig.BLOCK_SIZE * WorldConfig.CHUNK_SIZE * position
end

function Builder:GetChunkBlockPositionBounds(position: Vector3)
	--local min = WorldConfig.CHUNK_SIZE*(position - Vector3.one/2) + Vector3.one
	--local max = WorldConfig.CHUNK_SIZE*(position + Vector3.one/2)
	
	local min = Builder:BlockIndexToBlockPosition(Vector3.one, position)
	local max = Builder:BlockIndexToBlockPosition(WorldConfig.CHUNK_SIZE * Vector3.one, position)
	return min, max
end

function Builder:LoopThroughAdjacents(position: Vector3, callback: (any))
	local dirs = {Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), Vector3.new(-1, 0, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, -1)}
	for _, dir in dirs do
		local v = callback(position + dir)
		if v then
			return v
		end
	end
end

function Builder:GetAdjacentBlocks()
	
end

function Builder:ChunkIterate(chunk, callback)
	for a, _ in pairs(chunk) do
		for b, _ in pairs(_) do
			for c, v in pairs(_) do
				callback(a, b, c, v)
			end
		end
	end
end

--function Builder:TensorIterate(tensor, dim, callback, ...)
--	local pts = {...}
--	for i, v in pairs(tensor) do
--		if dim > 1 and type(v) == "table" then
--			table.insert(pts, i)
--			Builder:TensorIterate(v, dim-1, callback, table.unpack(...))
--		else
--			callback(table.unpack(...), v)
--		end
--	end
--end

function Builder:XYZIterate(amount, callback)
	for x = 1, amount do
		for y = 1, amount do
			for z = 1, amount do
				callback(x, y, z)
			end
		end
	end
end

function Builder:BrickCombine(brick1, brick2)
	
end

function Builder:BrickSeperate(brick1, brick2)
	
end

function Builder:GetBrickDimension(brick)
	local dim = 0
	if brick.Length > 1 then
		dim += 1
	end
	if brick.Width > 1 then
		dim += 1
	end
	if brick.Height > 1 then
		dim += 1
	end
	return dim
end

return Builder

--function TensorIterate(tensor, dim, callback, ...)
--	for k, v in pairs(tensor) do
--		if dim > 1 and type(v) == "table" then
--			local args = table.unpack(...)
--			print(args)
--			table.insert(args, k)
--			TensorIterate(v, dim-1, callback, table.unpack(args))
--		else
--			callback(..., k, v)
--		end
--	end
--end

--TensorIterate({ {1}, {2} }, 1, function(...)
--	print(...)
--end)
