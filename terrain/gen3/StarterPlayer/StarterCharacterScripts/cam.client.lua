local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
while task.wait() do
	local rootPos = root.Position
	local camera = workspace.CurrentCamera
	local camPos = camera.CFrame.Position
	local camLook = camera.CFrame.LookVector
	local angle = camera.MaxAxisFieldOfView/2
	local newCFrame = CFrame.new(rootPos,camLook)
	local LB = camera.CFrame:ToWorldSpace(CFrame.Angles(0,math.rad(angle),0))
	local RB = camera.CFrame:ToWorldSpace(CFrame.Angles(0,-math.rad(angle),0))
	local s = 64+(Vector2.new(camPos.X,camPos.Z)-Vector2.new(rootPos.X,rootPos.Z)).Magnitude


	local lockedPos = Vector3.new(camPos.X,4,camPos.Z)
	local lockedLB = Vector3.new(LB.LookVector.X,0,LB.LookVector.Z)
	local lockedRB = Vector3.new(RB.LookVector.X,0,RB.LookVector.Z)


	workspace.p1.Position = lockedPos + lockedLB * s
	workspace.p2.Position = lockedPos + lockedRB * s
	--workspace.p3.Position = camPos + camLook * s
end
