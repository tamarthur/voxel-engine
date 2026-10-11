local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local Assets = ServerStorage.Assets
local Characters = Assets.Characters

local CharacterObject = require(ReplicatedStorage.Modules.Util.InstanceWrapper)()

function CharacterObject.new(player, characterType)
	local starterCharacter = Characters[characterType or "Default"]:Clone()
	starterCharacter.Name = player.Name

	for _, obj in ipairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do
		obj:Clone().Parent = starterCharacter
	end
	
	Instance.new("Attachment", starterCharacter.HumanoidRootPart)
	
	local self = {
		_instance = starterCharacter,
		Player = player
	}
	return setmetatable(self, CharacterObject)
end

function CharacterObject:Destroy()
	self._instance:Destroy()
	setmetatable(self, nil)
end

return CharacterObject
