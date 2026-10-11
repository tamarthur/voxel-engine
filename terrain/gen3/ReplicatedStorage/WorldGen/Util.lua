local Config = require(game.ReplicatedStorage.WorldGen.Config)
local Util = {}

function Util.BlockToChunkGrid(x)
	return x/Config.BlockSize*Config.ChunkSize
end

function Util.ChunkToBlockGrid(x)
	return x*Config.BlockSize*Config.ChunkSize
end

function Util.SetNestedTable(list,...)
	local vars = {...}
	local curr = list
	for i,v in pairs(vars) do
		if type(v) == "table" then
			curr[v[1]] = v[2]
			break
		end
		if not curr[v] then
			curr[v] = {}
		end
		curr = curr[v]
	end
	return list
end

return Util
