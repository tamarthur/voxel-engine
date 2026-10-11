local ServerStorage = game.ServerStorage
local WorldGenerator = require(script.Parent.WorldGenerator)

local Storage = game.ReplicatedStorage.Storage
local Modules = ServerStorage.Modules
local Objects = Modules.Objects

local ProfileService = require(Modules.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("PlayerData", {
	Cash = 0,
	Items = {},
	LogInTimes = 0,
})

local PlayerObject = require(Objects.PlayerObject)

local SessionHandler = {}

function SessionHandler.onCharacterAdded(characterInstance)
	
end

function SessionHandler.onPlayerLoaded(playerInstance, profile)
	local player = PlayerObject.new(playerInstance)
	player.Profile = profile
	player.Data = profile.Data
	
	game.ReplicatedFirst.Loading:Clone().Parent = player:WaitForChild("PlayerGui")
	
	SessionHandler.PlayerCache[playerInstance.Name] = player
	WorldGenerator.Loaded:Wait()
	player:LoadCharacter(workspace.Live, true)
end

function SessionHandler.onPlayerAdded(playerInstance)
	local profile = ProfileStore.Mock:LoadProfileAsync("Player_" .. playerInstance.UserId)
	if profile ~= nil then
		profile:AddUserId(playerInstance.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			local player = SessionHandler.PlayerCache[playerInstance.Name]
			if player then
				player:Destroy()
			end
			-- The profile could've been loaded on another Roblox server:
			playerInstance:Kick("Profile loaded elsewhere")
		end)
		if playerInstance:IsDescendantOf(game.Players) == true then
			-- A profile has been successfully loaded:
			SessionHandler.onPlayerLoaded(playerInstance, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		playerInstance:Kick("Error while loading profile") 
	end
end

function SessionHandler.onPlayerRemoving(playerInstance)
	local player = SessionHandler.PlayerCache[playerInstance.Name]
	if player and player.Profile ~= nil then
		player.Profile:Release()
	end
	SessionHandler.PlayerCache[playerInstance.Name] = nil
end

function SessionHandler.loadClientScripts()
	for _, module in ipairs(ServerStorage.StarterPlayer.StarterPlayerScripts:GetChildren()) do
		module:Clone().Parent = game.StarterPlayer.StarterPlayerScripts
	end
end

function SessionHandler.Init()
	SessionHandler.loadClientScripts()
	SessionHandler.PlayerCache = require(Storage.PlayerCache)
	
	game.Players.PlayerAdded:Connect(SessionHandler.onPlayerAdded)
	game.Players.PlayerRemoving:Connect(SessionHandler.onPlayerRemoving)
	game:BindToClose(function()
		for _, player in ipairs(game.Players:GetPlayers()) do
			player:Kick("Server has been shut down")
		end
	end)
end

return SessionHandler
