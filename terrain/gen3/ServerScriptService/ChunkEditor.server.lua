local worldGen = game.ReplicatedStorage.WorldGen
local modules = game.ReplicatedStorage.Modules

local remotes = game.ReplicatedStorage.Remotes

local PartCache = require(modules.PartCache)
local Encode = require(modules.Encode)

local Chunk = require(worldGen.Chunk)
local BlockEnum = require(worldGen.BlockEnum)
local Config = require(worldGen.Config)
local Util = require(worldGen.Util)
local GlobalChunkGrid = require(game.ServerStorage.GlobalChunkGrid)

remotes.Mine.OnServerEvent:Connect(function(player,brick,pos)
	print(brick)
	brick.Parent.Name:gsub('(.*)x(.*)', function (x,z)
		local blockX = x-pos.X
		local blockZ = z-pos.Z
		local chunk = brick.Parent.Name[x][z][blockX][blockZ][pos.Y]
		
		
	end)
end)
