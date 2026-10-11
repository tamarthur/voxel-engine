print("limit")
wait(5)

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--HumanoidRootPart:GetPropertyChangedSignal("Anchored"):Wait()

wait(1)

print("ran")

game:GetService("RunService").RenderStepped:Connect(function(dt)
	local velocity = HumanoidRootPart.Velocity
	HumanoidRootPart.Velocity = velocity.Unit * math.min(velocity.Magnitude, 80)
	Character:SetAttribute("Velocity", HumanoidRootPart.Velocity)
	Character:SetAttribute("Magnitude", HumanoidRootPart.Velocity.Magnitude)
end)
