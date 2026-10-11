local ChunkGenerator = {
	Ports = {}
}

local HttpService = game:GetService("HttpService")
local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local modules = ServerStorage.Modules
local sharedModules = ReplicatedStorage.Modules
local sharedData = ReplicatedStorage.SharedData	
local serverData = ServerStorage.ServerData
local remotes = ReplicatedStorage.Remotes

local base93 = require(sharedModules.base93)

local GlobalChunkGrid = require(serverData.GlobalChunkGrid)
local BlockEnum = require(sharedModules.BlockEnum)
local BlockConfig = require(sharedModules.BlockConfig)

local TerrainGenerator = require(script.TerrainGenerator)

function gridToMap(noise)
	return math.floor(noise/BlockConfig.BlockSize)*BlockConfig.BlockSize
end

function getBlock(noise)
	if noise < -.2 then
		return "Snow"
	elseif noise >= -.2 and noise < .15 then
		return "Plains"
	elseif noise >= .15 and noise < .7 then
		return "Desert"
	elseif noise >= .7  then
		return "Red"
	end
	return "Blue"
end

function ChunkGenerator.Init()
	local terrainGenerator = TerrainGenerator.new()
	local VegetationChance = Random.new(69696)
	
	--function ChunkGenerator.Ports.GetChunk(player, grid)
		
	--end
	
	remotes.GetChunk.OnServerEvent:Connect(function(player,grid)
		grid = HttpService:JSONDecode(base93.decompress(grid))
		local generatedGrid = {}
		for _, pt in pairs(grid) do
			local cx, cz = table.unpack(pt)
			local key = cx.." "..cz
			local chunk = GlobalChunkGrid[key]
			if chunk then
				generatedGrid[key] = chunk
				continue
			end
			chunk = {}
			for x = 1, 16 do
				for z = 1, 16 do
					local bx = (cx * 16) + x - BlockConfig.ChunkSize/2
					local bz = (cz * 16) + z - BlockConfig.ChunkSize/2
					
					local y, blockID = terrainGenerator:Generate(bx,nil,bz)

					if not chunk[y] then
						chunk[y] = {}
					end
					if not chunk[y][blockID] then
						chunk[y][blockID] = {}
					end
					
					chunk[y][blockID][z.." "..x] = true
				end
			end
			generatedGrid[key] = chunk
			GlobalChunkGrid[key] = chunk
		end
		generatedGrid = base93.compress(HttpService:JSONEncode(generatedGrid))
		remotes.GetChunk:FireClient(player,generatedGrid)
	end)
	
	remotes.Mine.OnServerEvent:Connect(function(player, brick, position)
		local x = math.floor(position.X/64 + .5)
		local z = math.floor(position.Z/64 + .5)
		remotes.Mine:FireClient(player, brick, position, {x, z})
	end)
	
end

return ChunkGenerator
