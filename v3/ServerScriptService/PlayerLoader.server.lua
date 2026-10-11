local Modules = game.ServerStorage.Modules
local SessionService = require(Modules.SessionService)

local RunService = game:GetService("RunService")

function MoveCharacterFolder(Character: Model, Folder)
	RunService.PostSimulation:Wait()

	Character.Parent = workspace.Live
end

function CharacterAdded(Character)
	coroutine.wrap(MoveCharacterFolder)(Character, workspace.Live)
end

function PlayerAdded(Player)
	SessionService:PlayerAdded(Player)
	Player.CharacterAdded:Connect(CharacterAdded)
end

function PlayerRemoving(Player)
	SessionService:PlayerRemoving(Player)
end

game.Players.PlayerAdded:Connect(PlayerAdded)
game.Players.PlayerRemoving:Connect(PlayerRemoving)

--local Tensor = require(game.ReplicatedStorage.Modules.Utility.Tensor).new(3)
--Tensor[1][2][3] = true
--print(Tensor:Get(1, 2, 3))
--print(Tensor:Get(1, 2))
--print(Tensor[1][2][3])
