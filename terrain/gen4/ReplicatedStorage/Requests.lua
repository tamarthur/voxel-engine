local Requests = {}

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

function Requests.Init(localHubs)
	if RunService:IsClient() then
		Requests.Player = game.Players.LocalPlayer
		local setUpEvent
		setUpEvent = script.Setup.OnClientEvent:Connect(function(data)
			for hub, events in pairs(data) do
				local ports = {}
				for name, remote in pairs(events) do
					ports[name] = script:WaitForChild(remote)
				end
				Requests[hub] = ports
			end
			script.Setup:Destroy()
			setUpEvent:Disconnect()
		end)
	else
		local playerStorage = require(game.ServerStorage.ServerData.PlayerStorage)
		local clientHub = {}
		for name, module in pairs(game.ServerScriptService.main:GetChildren()) do
			local ports = require(module).Ports
			if not ports then continue end
			local hub = {}
			for event, eventFunction in pairs(ports) do
				local remoteEvent = Instance.new("RemoteEvent",script)
				local remoteID = HttpService:GenerateGUID(true)
				remoteEvent.Name = remoteID
				remoteEvent.OnServerEvent:Connect(function(player, ...)
					local playerWrapper = playerStorage[player.Name]
					eventFunction(playerWrapper, ...)
				end)
				hub[event] = remoteID
			end
			Requests[name] = hub
			clientHub[name] = hub
		end
		game.Players.PlayerAdded:Connect(function(player)
			script.Setup:FireClient(player,clientHub)
		end)
	end
	
	for name, events in pairs(localHubs) do
		local ports = {}
		for name, event in pairs(events) do
			ports[name] = event
		end
		Requests[name] = events
	end
end

function Requests.Post(port,event,...)
	local port = Requests[port]
	if port and port[event] then
		
	end
end

function Requests.GetPorts()
	for i,v in pairs(game.ServerScriptService.main:GetChildren()) do
		
	end
end

return Requests
