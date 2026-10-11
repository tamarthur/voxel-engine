local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ServerStorage.Modules
local sharedModules = ReplicatedStorage.Modules

local CharacterObject = require(modules.CharacterObject)
local InstanceWrapper = require(sharedModules.InstanceWrapper)
local Signal = require(sharedModules.Signal)

local PlayerObject = InstanceWrapper()

function PlayerObject.new(playerInstance)
	local self = setmetatable({_instance = playerInstance},PlayerObject)
	self:AddEvent("CharacterAdded")
	self._characterAddedEvent = playerInstance.CharacterAdded:Connect(function(character)
		self.Character = CharacterObject.new(self, character)
		self.CharacterAdded:Fire(self.Character)
	end)
	self.Settings = {
		RenderDistance = 12,
	}
	return self
end

function PlayerObject:Test(a)
	print("Testing")
end

function PlayerObject:Destroy()
	self.CharacterAdded:DisconnectAll()
	self._characterAddedEvent:Disconnect()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return PlayerObject
