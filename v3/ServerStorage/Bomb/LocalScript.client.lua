local UIS = game:GetService("UserInputService")
local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local Remotes = game.ReplicatedStorage.Remotes

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Camera = workspace.CurrentCamera

local Visualizer = Instance.new("Part",workspace)
Visualizer.Anchored = true
Visualizer.CanCollide = false
Visualizer.Transparency = 1
Visualizer.Size = WorldConfig.BLOCK_SIZE * Vector3.one
Visualizer.Position = 1e4 * Vector3.one
local Selection = Instance.new("SelectionBox", Visualizer)
Selection.Adornee = Visualizer
Selection.Color3 = Color3.new(1)

local HeartbeatEvent

script.Parent.Equipped:Connect(function()
	HeartbeatEvent = game:GetService("RunService").RenderStepped:Connect(function()
		Selection.Adornee = Visualizer
		local mousePosition = UIS:GetMouseLocation()
		local unitRay = Camera:ViewportPointToRay(mousePosition.x, mousePosition.y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = {workspace.Chunks}

		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction*50, raycastParams)

		if raycastResult then 
			Visualizer.Position = WorldBuilder:MapPositionToGrid(raycastResult.Position - raycastResult.Normal * 2)
		end
	end)
end)

script.Parent.Unequipped:Connect(function()
	Selection.Adornee = nil
	HeartbeatEvent:Disconnect()
end)

script.Parent.Activated:Connect(function()
	local pos = Visualizer.Position
	local chunkPos = WorldBuilder:StudPositionToChunkPosition(pos)
	local blockIndex = WorldBuilder:StudPositionToBlockIndex(pos, chunkPos)
	--print(pos)
	--print(WorldBuilder:StudToBlockPosition(pos))
	--print(chunkPos)
	--print(blockIndex)
	script.Parent.RemoteEvent:FireServer(chunkPos.X, chunkPos.Y, chunkPos.Z, blockIndex.X, blockIndex.Y, blockIndex.Z)
	Selection.Adornee = nil
end)
