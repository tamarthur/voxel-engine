local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local tool = script.Parent
local cursor = tool.Cursor
local brick

local mousePosition = Vector3.new()

local RAY_DISTANCE = 100

local function round(x)
	return math.floor(x/4)*4
end

local function InputChanged(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mousePosition = input.Position
		
		local rayData = workspace.CurrentCamera:ScreenPointToRay(mousePosition.X, mousePosition.Y, 0)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local raycastResult = workspace:Raycast(rayData.Origin, rayData.Direction * 100, raycastParams)
		if raycastResult then
			brick = raycastResult.Instance
			--brick.Color = Color3.new(1,1,1)
			local position = raycastResult.Position + raycastResult.Normal * -2
			position = Vector3.new(round(position.X)+2,round(position.Y)+2,round(position.Z)+2)
			cursor.Position = position
			local x = math.floor(position.X/64 + .5)
			local z = math.floor(position.Z/64 + .5)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		game.ReplicatedStorage.Remotes.Mine:FireServer(brick, cursor.Position)
	end
end)
UserInputService.InputChanged:Connect(InputChanged)
