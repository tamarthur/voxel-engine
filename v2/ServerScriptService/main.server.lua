local WorldGenerator = require(script.WorldGenerator)
local SessionHandler = require(script.SessionHandler)
local Requests = require(game.ReplicatedStorage.Requests)

WorldGenerator.Init()
Requests.Init()
require(script.WorldQuery).Init()
SessionHandler.Init()

--WorldGenerator.Start()
