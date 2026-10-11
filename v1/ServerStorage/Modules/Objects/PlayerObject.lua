local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ServerStorage.Modules
local Util = Modules.Util
local Objects = Modules.Objects

local ProfileService = require(Modules.ProfileService)
local CharacterObject = require(Objects.CharacterObject)

local PlayerObject = require(ReplicatedStorage.Modules.Util.InstanceWrapper)()

function PlayerObject.new(playerInstance)
	local self = {
		_instance = playerInstance
	}
	
	--for i,v in pairs(playerInstance:GetChildren()) do
	--	print(i,v)
	--end
	
	--local playerScripts = playerInstance:WaitForChild("PlayerScripts")
	--for _, module in ipairs(ServerStorage.StarterPlayer.StarterPlayerScripts:GetChildren()) do
	--	module:Clone().Parent = playerScripts
	--end
	
	return setmetatable(self, PlayerObject)
end

function PlayerObject:LoadCharacter(parent)
	--overide
	local character = CharacterObject.new(self, "MyCharacter")
	self._instance.Character = character._instance
	rawset(self, "Character", character)
	
	character._instance:SetPrimaryPartCFrame(CFrame.new(0,500,0))
	character._instance.Parent = parent or workspace
end

function PlayerObject:UnloadCharacter()
	--overide 
	
end

function PlayerObject:SaveCharacter()
	--overide 
	
end

function PlayerObject:SaveData()
	--overide 

end

function PlayerObject:Destroy()
	if self.Character then	
		self.Character:Destroy()
	end
	setmetatable(self, nil)
end

return PlayerObject
