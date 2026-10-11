local ReplicatedStorage = game.ReplicatedStorage
--local Requests = require(ReplicatedStorage.Requests)
local modules = ReplicatedStorage.Modules

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
script.Mine.Event:Connect(function(brick,position)
	local x = math.floor(position.X/64 + .5)
	local z = math.floor(position.Z/64 + .5)
	
end)

local modules = {}

for _, v in ipairs(game.StarterPlayer.client:GetChildren()) do
	local module = require(v)
	if module.Init == nil then continue end
	module.Init()
end

--game:GetService("RunService").RenderStepped:Connect(function()
--	local position = humanoidRootPart.Position
--	local x = math.floor(position.X/64 + .5)
--	local z = math.floor(position.Z/64 + .5)
--	print(x,z)
--	workspace.Center.Position = Vector3.new(x*64,-10,z*64)
--end)
