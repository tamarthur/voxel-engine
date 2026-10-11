local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local GridService = require(game.ServerStorage.Modules.GridService)
script.Parent.RemoteEvent.OnServerEvent:Connect(function(player, cx, cy, cz, x, y ,z)
	local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
	
	for x1 = -4, 4 do
		for y1 = -4, 4 do
			for z1 = -4, 4 do
				local newPosition = Vector3.new(x1, y1, z1)
				if (blockPosition + newPosition).Magnitude > 8 then continue end
				local blockPosition, chunkPosition = WorldBuilder:BlockPositionToBlockIndex(newPosition)
				local chunkKey = WorldBuilder:CoordinatesToKey(WorldBuilder:GetComponents(chunkPosition))
				
				GridService:RemoveBlock(chunkPosition.X ,chunkPosition.Y, chunkPosition.Z, blockPosition.X, blockPosition.Y, blockPosition.Z)
			end
		end
	end
	
end)
