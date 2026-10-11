local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage
local modules = ServerStorage.Modules
local sharedModules = ReplicatedStorage.Modules

local InstanceWrapper = require(sharedModules.InstanceWrapper)

local CharacterObject = InstanceWrapper()

function CharacterObject.new(player, characterInstance)
	local self = setmetatable({_instance = characterInstance},CharacterObject)
	self.Player = player
	return self
end

function CharacterObject:InitRender()
	
end

function CharacterObject:GetChunkPosition()
	local position = self:WaitForChild("HumanoidRootPart").Position
	local x = math.floor(position.X/64 + .5)
	local z = math.floor(position.Z/64 + .5)
	return x, z
end

return CharacterObject
