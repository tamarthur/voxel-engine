local Storage = game.ReplicatedStorage.Storage
local Util = game.ReplicatedStorage.Modules.Util
local Signal = require(Util.Signal)

local RequestRemote = {}
RequestRemote.__index = RequestRemote

function RequestRemote.new(name)
	local remote = Instance.new("RemoteEvent", game.ReplicatedStorage.Remotes)
	remote.Name = game:GetService("HttpService"):GenerateGUID()
	
	local self = {
		_remote = remote,
		Name = name,
		OnServerEvent = Signal.new()
	}
	
	self._onServerEvent = remote.OnServerEvent:Connect(function(player, ...)
		local playerSessionStorage = require(Storage.PlayerSessions)
		local playerSession = playerSessionStorage[player.Name]
		
		self.OnServerEvent:Fire(playerSession, ...)
	end)
	
	return setmetatable(self, RequestRemote)
end

function RequestRemote:Destroy()
	self._remote:Destroy()
	self._onServerEvent:Disconnect()
	self.OnServerEvent:Disconnect()
	setmetatable(self, nil)
end

return RequestRemote
