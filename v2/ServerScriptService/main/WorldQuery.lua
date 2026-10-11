local HttpService = game:GetService("HttpService")
local Requests = require(game.ReplicatedStorage.Requests)

local WorldGenerator = require(script.Parent.WorldGenerator)

local base93 = require(game.ReplicatedStorage.Modules.Util.base93)
local WorldUtil = require(game.ReplicatedStorage.Modules.Terrain.WorldUtil)
local WorldGrid = require(game.ReplicatedStorage.Modules.Terrain.WorldGrid)

local WorldHandler = {}

function WorldHandler.Init()
	Requests.GetChunks.OnServerEvent:Connect(function(player, query, dx, dy, dz)
		query = HttpService:JSONDecode(base93.decompress(query))
		
		local character = player.Character
		local rootPart = character.HumanoidRootPart
		local mx, my, mz = WorldUtil.globalToChunkPosition(rootPart.Position)
		if not character.LastChunkPosition then
			character.LastChunkPosition = {mx, my + 1, mz}
		end
		rootPart.Anchored = true
		
		local direction = Vector3.new(mx, my, mz) - Vector3.new(table.unpack(character.LastChunkPosition))
		local requested, updated = WorldGenerator.GenerateChunks(mx, my, mz, direction, query)
		
		if #updated > 0 then
			Requests.UpdateChunks:FireClient(player, updated)
		end
		
		rootPart.Anchored = false
		Requests.GetChunks:FireClient(player, requested)
		character.LastChunkPosition = {mx, my, mz}
	end)
end

return WorldHandler
