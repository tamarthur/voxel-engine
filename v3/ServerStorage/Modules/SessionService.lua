local ProfileService = require(script.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("PlayerData", require(script.DefaultData)).Mock

local SessionService = {}
SessionService.Sessions = {}

function SessionService:PlayerAdded(player: Player, callback: (any))
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			SessionService.Sessions[player.Name] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(game.Players) == true then
			SessionService.Sessions[player.Name] = profile
			-- A profile has been successfully loaded:
			if callback then callback(profile) end
			--DoSomethingWithALoadedProfile(player, Profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick() 
	end
end

function SessionService:PlayerRemoving(player: Player)
	local profile = SessionService.Sessions[player.Name]
	if profile ~= nil then
		profile:Release()
	end
	SessionService.Sessions[player.Name] = nil
end

function SessionService:GetData(playerName: string, path: string)
	local data = SessionService.Sessions[playerName].Data

	for _, level in pairs(path and path:split(".") or {}) do
		data = data[tonumber(level) or level]
	end
	
	return data
end

function SessionService:SetData(playerName: string, path: string, value: any)
	local data = SessionService.Sessions[playerName].Data
	local hierarchy = path:split(".")
	
	local function convert(datatype)
		return tonumber(datatype) or datatype
	end
	
	for i = 1, #hierarchy-1 do
		data = data[convert(hierarchy[i])]
	end
	data[convert(hierarchy[#hierarchy])] = value
end

return SessionService
