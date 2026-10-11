local PlayerCache = require(game.ReplicatedStorage.Storage.PlayerCache)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Requests = {}

function Requests.Init()
	if not game:GetService("RunService"):IsServer() then return end
	for _, remote in ipairs(script:GetChildren()) do
		if remote:IsA("RemoteEvent") then
			
			Requests[remote.Name] = {
				OnServerEvent = Signal.new(),
				FireClient = function(_, player, ...)
					remote:FireClient(player._instance, ...)
				end,
			}
			remote.OnServerEvent:Connect(function(player, ...)
				Requests[remote.Name].OnServerEvent:Fire(PlayerCache[player.Name], ...)
			end)
			
		elseif remote:IsA("RemoteFunction") then
			
			remote.OnServerInvoke = function(player, ...)
				return Requests[remote.Name](PlayerCache[player.Name], ...)
			end
		
		end
	end
end

return Requests
