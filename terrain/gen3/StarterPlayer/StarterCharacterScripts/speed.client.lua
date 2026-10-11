local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")


character:WaitForChild("Humanoid").WalkSpeed = 40
character:WaitForChild("Humanoid").JumpHeight = 5
if game:GetService("RunService"):IsStudio() then
	player.CameraMaxZoomDistance = 1e99
	game.Lighting.Atmosphere:Destroy()
end

game:GetService("RunService").RenderStepped:Connect(function()
	if humanoidRootPart.Position.Y < -256 then
		humanoidRootPart.Velocity = Vector3.new(0,0,0)
		character:MoveTo(humanoidRootPart.Position + Vector3.new(0,512,0))
	end
end)
