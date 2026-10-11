local ProfileService = require(game.ServerStorage.Modules.ProfileService)

local DataConfig = {
	ProfileService = ProfileService,
	ProfileStore = ProfileService.GetProfileStore("PlayerData", {
		Cash = 0,
		Items = {},
		LogInTimes = 0,
	}),
}

return DataConfig
