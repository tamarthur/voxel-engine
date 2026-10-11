local HttpService = game:GetService("HttpService")
local Requests = require(game.ReplicatedStorage.Requests)

local base93 = require(game.ReplicatedStorage.Modules.Util.base93)
local WorldUtil = require(game.ReplicatedStorage.Modules.Terrain.WorldUtil)
local WorldGrid = require(game.ReplicatedStorage.Storage.WorldGrid)

local WorldHandler = {}

function WorldHandler.Init()
	Requests.GetChunks.OnServerEvent:Connect(function(player, query)
		query = HttpService:JSONDecode(base93.decompress(query))
		local chunks = {}
		
		for _, pt in pairs(query) do
			local cx, cy, cz = table.unpack(pt)
			local key = WorldUtil.stringify(cx, cy, cz)
			local chunk = WorldGrid[key]
			
			if not chunk then continue end
			chunks[key] = chunk.Hull
		end
		Requests.GetChunks:FireClient(player, chunks)
	end)
end

return WorldHandler
