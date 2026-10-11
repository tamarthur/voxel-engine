local GridService = require(game.ServerStorage.Modules.GridService)
script.Parent.RemoteFunction.OnServerInvoke = function(player, cx, cy, cz, x, y, z)
	return GridService:GetBlock(cx, cy, cz, x, y, z)
end

script.Parent.a.OnServerInvoke = function(player, key)
	print(GridService:_debugChunk(key))
end
