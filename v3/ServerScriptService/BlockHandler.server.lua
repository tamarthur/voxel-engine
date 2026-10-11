local GridService = require(game.ServerStorage.Modules.GridService)
local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local Remotes = game.ReplicatedStorage.Remotes
local Queue = {}

Remotes.Place.OnServerEvent:Connect(function(player, cx, cy, cz, x, y, z, blockID)
	local queueKey = WorldBuilder:CoordinatesToKey(cx, cy, cz, x, y, z)
	if Queue[queueKey] then return end
	
	local overlapParams = OverlapParams.new()
	overlapParams.MaxParts = 1
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {workspace.Live}
	
	local position = WorldBuilder:BlockIndexToStudPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
	local size = (WorldConfig.BLOCK_SIZE)*Vector3.one

	if next(workspace:GetPartBoundsInBox(CFrame.new(position), size, overlapParams)) then return end
	
	Queue[queueKey] = true
	if GridService:AddBlock(cx, cy, cz, x, y, z, blockID) then
		Remotes.Update:FireAllClients({{cx, cy, cz, x, y, z, blockID}})
	end
	Queue[queueKey] = nil
end)

Remotes.Break.OnServerEvent:Connect(function(player, cx, cy, cz, x, y, z)
	--local queueKey = WorldBuilder:CoordinatesToKey(cx, cy, cz, x, y, z)
	--if Queue[queueKey] then return end
	--Queue[queueKey] = true
	
	local dirs = {Vector3.zero, table.unpack(WorldConfig.DIRECTION_MAP)}
	local queueKeys = {}
	
	local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
	for _, dir in pairs(dirs) do
		local adjacentPosition = blockPosition + dir
		local blockIndex, chunkPosition = WorldBuilder:BlockPositionToBlockIndex(adjacentPosition)
		
		local queueKey = WorldBuilder:CoordinatesToKey(WorldBuilder:GetComponents(chunkPosition), blockIndex.X, blockIndex.Y, blockIndex.Z)
		if Queue[queueKey] then return end
		
		table.insert(queueKeys, queueKey)
	end
	
	for _, key in pairs(queueKeys) do
		Queue[key] = true
	end
	
	local updatedBlocks = GridService:RemoveBlock(cx, cy, cz, x, y, z)
	if updatedBlocks then
		Remotes.Update:FireAllClients(updatedBlocks)
		--Remotes.Update:FireAllClients({{cx, cy, cz, x, y, z}})
	end
	--Queue[queueKey] = nil
	for _, key in pairs(queueKeys) do
		Queue[key] = nil
	end
end)

Remotes.GetChunks.OnServerInvoke = function(player, chunks)
	return GridService:GetChunks(chunks)
end
