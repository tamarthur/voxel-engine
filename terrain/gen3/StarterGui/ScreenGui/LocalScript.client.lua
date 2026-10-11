local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function round(x)
	return math.floor(x/4)
end

local render = script.Parent.Render
local distance = 12
local function updateDistance(x)
	distance = math.clamp(distance + x, 4, 24)
	render.Display.Text = "Render: "..distance
	player:SetAttribute("RenderDistance",distance)
end

updateDistance(0)
render.Sub.MouseButton1Click:Connect(function()
	updateDistance(-2)
end)
render.Add.MouseButton1Click:Connect(function()
	updateDistance(2)
end)

while wait() do
	local text = "(X,Y,Z): ("..round(humanoidRootPart.Position.X)..", "..round(humanoidRootPart.Position.Y)..", "..round(humanoidRootPart.Position.Z)..")"
	
	script.Parent.Coordinates.Text = text
end
