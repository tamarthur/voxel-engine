local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local mouse = player:GetMouse()
mouse.TargetFilter = character

local tool = script.Parent
local cursor = tool.Cursor

local function round(x)
	return math.floor(x/4+.5)*4
end

local pos
local target
mouse.Move:Connect(function()
	target = mouse.Target
	local hit = mouse.Hit
	local hitPos = mouse.Hit.Position + mouse.UnitRay.Direction * 4
	pos = Vector3.new(round(hitPos.X),round(hitPos.Y),round(hitPos.Z))
	cursor.Position = pos
end)

tool.Equipped:Connect(function()
	tool.Activated:Connect(function()
		if not target then return end
		--game.ReplicatedStorage.Remotes.Mine:FireServer(target,pos)
	end)
end)

tool.Unequipped:Connect(function()
	cursor.CFrame = CFrame.new(0,-1000,0)
end)

