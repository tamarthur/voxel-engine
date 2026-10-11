local BaseRequest = {}

function BaseRequest.new(remoteObject)
	remoteObject.Name = game:GetService("HttpService"):GenerateGUID()
	remoteObject.Parent = game.ReplicatedStorage.Remotes

	local self = {
		_remote = remoteObject
	}
	return setmetatable(self, BaseRequest)
end

return BaseRequest
