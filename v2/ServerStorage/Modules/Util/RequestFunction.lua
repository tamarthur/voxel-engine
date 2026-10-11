local Storage = game.ReplicatedStorage.Storage
local Util = game.ReplicatedStorage.Modules.Util
local Signal = require(Util.Signal)

local RequestFunction = {}
RequestFunction.__index = RequestFunction

function RequestFunction.new(name)
	local remote = Instance.new("RemoteFunction", game.ReplicatedStorage.Remotes)
	remote.Name = game:GetService("HttpService"):GenerateGUID()
	
	local self = {
		_remote = remote,
		Name = name,
	}
	
	remote.OnServerInvoke = function(player, ...)
		local playerSessionStorage = require(Storage.PlayerSessions)
		local playerSession = playerSessionStorage[player.Name]
		
		self.OnServerInvoke(playerSession, ...)
	end

	return setmetatable(self, RequestFunction)
end

function RequestFunction:Destroy()
	self._remote:Destroy()
	self.OnServerInvoke = nil
	setmetatable(self, nil)
end

return RequestFunction
