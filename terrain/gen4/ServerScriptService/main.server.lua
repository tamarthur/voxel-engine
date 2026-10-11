local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ServerStorage.Modules
local serverData = ServerStorage.ServerData

local PlayerObject = require(modules.PlayerObject)
local PlayerStorage = require(serverData.PlayerStorage)

game.Players.PlayerAdded:Connect(function(playerInstance)
	local player = PlayerObject.new(playerInstance)
	PlayerStorage[playerInstance.Name] = player
end)

game.Players.PlayerRemoving:Connect(function(playerInstance)
	local player = PlayerStorage[playerInstance.Name]
	player:Destroy()
	PlayerStorage[playerInstance.Name] = nil
end)

for _, v in ipairs(script:GetChildren()) do
	local module = require(v)
	if module.Init == nil then continue end
	module.Init()
end
