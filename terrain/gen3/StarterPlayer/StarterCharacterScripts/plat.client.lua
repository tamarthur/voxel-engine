local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

game:GetService("RunService").RenderStepped:Connect(function()
	workspace.plat.Position = Vector3.new(humanoidRootPart.Position.X,workspace.plat.Position.Y,humanoidRootPart.Position.Z)
end)
