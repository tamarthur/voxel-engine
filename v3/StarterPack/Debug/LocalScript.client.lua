local UIS = game:GetService("UserInputService")
local WorldConfig = require(game.ReplicatedStorage.Modules.Utility.WorldConfig)
local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
local BlockData = require(game.ReplicatedStorage.Modules.Utility.BlockData)
local Remotes = game.ReplicatedStorage.Remotes

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Camera = workspace.CurrentCamera

local DisplayType = 1
local Distance = 25
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E then
		Distance = math.clamp(Distance + 4, 1, 100)
	elseif input.KeyCode == Enum.KeyCode.Q then
		Distance = math.clamp(Distance - 4, 1, 100)
	elseif input.KeyCode == Enum.KeyCode.X then
		DisplayType = DisplayType % 3 + 1
	end
end)

local Visualizer = Instance.new("Part",workspace)
Visualizer.Anchored = true
Visualizer.CanCollide = false
Visualizer.Transparency = 1
Visualizer.Size = WorldConfig.BLOCK_SIZE * Vector3.one
Visualizer.Position = 1e4 * Vector3.one

script.BillboardGui:Clone().Parent = Visualizer
local textLabel = Visualizer.BillboardGui.TextLabel

local Selection = Instance.new("SelectionBox", Visualizer)
Selection.Adornee = Visualizer
Selection.Color3 = Color3.new(1,1,1)

local HeartbeatEvent

script.Parent.Equipped:Connect(function()
	HeartbeatEvent = game:GetService("RunService").RenderStepped:Connect(function()
		Selection.Adornee = Visualizer
		local mousePosition = UIS:GetMouseLocation()
		local unitRay = Camera:ViewportPointToRay(mousePosition.x, mousePosition.y)
		
		local newPos = WorldBuilder:MapPositionToGrid(unitRay.Origin + unitRay.Direction*Distance)
		if Visualizer.Position ~= newPos then
			local pos = newPos
			local chunkPos = WorldBuilder:StudPositionToChunkPosition(pos)
			local blockIndex = WorldBuilder:StudPositionToBlockIndex(pos, chunkPos)
			if DisplayType == 1 then
				local blockID = script.Parent.RemoteFunction:InvokeServer(chunkPos.X, chunkPos.Y, chunkPos.Z, blockIndex.X, blockIndex.Y, blockIndex.Z)
				textLabel.Text = (blockID and blockID ~= 0) and BlockData[blockID].Name or "nil"
			elseif DisplayType == 2 then
				local x, y, z = WorldBuilder:GetComponents(WorldBuilder:StudPositionToBlockPosition(pos))
				textLabel.Text = "X: "..x.." Y: "..y.." Z: "..z
			elseif DisplayType == 3 then
				local blockIndex, chunkPos = WorldBuilder:BlockPositionToBlockIndex(WorldBuilder:StudPositionToBlockPosition(pos))
				local cx, cy, cz = WorldBuilder:GetComponents(chunkPos)
				local x, y, z = WorldBuilder:GetComponents(pos)
				textLabel.Text = "CX: "..x.." CY: "..y.." CZ: "..z.."\nX: "..x.." Y: "..y.." Z: "..z
			end
		end
		Visualizer.Position = newPos
		
		--local raycastParams = RaycastParams.new()
		--raycastParams.FilterType = Enum.RaycastFilterType.Include
		--raycastParams.FilterDescendantsInstances = {workspace.Chunks}

		--local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction*50, raycastParams)

		--if raycastResult then 
		--	Visualizer.Position = WorldBuilder:MapPositionToGrid(raycastResult.Position - raycastResult.Normal * 2)
		--else
		--	Visualizer.Position = WorldBuilder:MapPositionToGrid(unitRay.Origin + unitRay.Direction*50)
		--end
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
	Character:WaitForChild("WorldRenderer").Event:Fire(chunkPos.X, chunkPos.Y, chunkPos.Z, blockIndex.X, blockIndex.Y, blockIndex.Z)
	script.Parent.a:InvokeServer(chunkPos.X.." "..chunkPos.Y.." "..chunkPos.Z)
end)
