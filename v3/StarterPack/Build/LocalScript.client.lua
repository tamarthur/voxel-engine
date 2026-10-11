local UIS = game:GetService("UserInputService")
local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local BlockData = require(game.ReplicatedStorage.Modules.Utility.BlockData)
local Remotes = game.ReplicatedStorage.Remotes

local selectedBlock = 2
local GUI = script.Parent.ScreenGui
for i = 2, #BlockData do
	local button = Instance.new("TextButton", GUI.ScrollingFrame)
	button.BackgroundTransparency = 1
	button.TextColor3 = Color3.new(1,1,1)
	button.Text = BlockData[i].Name
	button.Name = BlockData[i].Name
	button.Size = UDim2.new(1,0,.03,0)
	button.TextScaled = true
	if i == selectedBlock then
		button.TextColor3 = Color3.new(1,1)
	end
	button.MouseButton1Click:Connect(function()
		GUI.ScrollingFrame[BlockData[selectedBlock].Name].TextColor3 = Color3.new(1,1,1)
		button.TextColor3 = Color3.new(1,1)
		selectedBlock = i
	end)
end

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

local HeartbeatEvent

script.Parent.Equipped:Connect(function()
	Selection.Adornee = Visualizer
	HeartbeatEvent = game:GetService("RunService").RenderStepped:Connect(function()
		local mousePosition = UIS:GetMouseLocation()
		local unitRay = Camera:ViewportPointToRay(mousePosition.x, mousePosition.y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = {workspace.Chunks}

		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction*50, raycastParams)

		local blockPosition = unitRay.Origin + unitRay.Direction*50
		if raycastResult then
			blockPosition = raycastResult.Position + raycastResult.Normal * WorldConfig.BLOCK_SIZE/2 --+ Visualizer.Size
		end
		Visualizer.Position = WorldBuilder:MapPositionToGrid(blockPosition)
	end)
	GUI.Parent = Player.PlayerGui
end)

script.Parent.Unequipped:Connect(function()
	Selection.Adornee = nil
	HeartbeatEvent:Disconnect()
	GUI.Parent = script.Parent
end)

script.Parent.Activated:Connect(function()
	local pos = Visualizer.Position
	local chunkPos = WorldBuilder:StudPositionToChunkPosition(pos)
	local blockIndex = WorldBuilder:StudPositionToBlockIndex(pos, chunkPos)	
	
	--print(pos)
	--print(WorldBuilder:StudPositionToBlockPosition(pos))
	--print(chunkPos)
	--print(blockIndex)
	Remotes.Place:FireServer(chunkPos.X, chunkPos.Y, chunkPos.Z, blockIndex.X, blockIndex.Y, blockIndex.Z, selectedBlock)
	--if Remotes.Place:FireServer(chunkPos.X, chunkPos.Y, chunkPos.Z, blockIndex.X, blockIndex.Y, blockIndex.Z, 1) then
	--	local block = Instance.new("Part", workspace)
	--	block.Anchored = true
	--	block.Position = Visualizer.Position
	--	block.Size = WorldConfig.BLOCK_SIZE * Vector3.one
	--end
end)
