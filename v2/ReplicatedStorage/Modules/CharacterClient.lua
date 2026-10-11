local CharacterClient = {}
CharacterClient.__index = CharacterClient

function CharacterClient.onHitRecieved(transmitter)
	
end

function CharacterClient.onHitTransmitted(receiver)
	
end

function CharacterClient:_dashProcess(dt, velocity)
	self.HumanoidRootPart.Velocity = velocity * self.DashVelocity
end


function CharacterClient:_getMass()
	local characterMass = 0
	for _, part in pairs(self._instance:GetDescendants()) do
		if part:IsA("Part") then
			characterMass += part:GetMass()
		end
	end
	return characterMass
end

function CharacterClient.new(characterInstance)
	if not characterInstance then return end
	if _G.Character then return _G.Character end
	local humanoidRootPart = characterInstance:WaitForChild("HumanoidRootPart")
	local humanoid = characterInstance:WaitForChild("Humanoid")
	humanoid.JumpPower = 0
	humanoid:ChangeState(Enum.HumanoidStateType.None)
	
	local self = setmetatable({
		_instance = characterInstance,
		_connections = {},
		
		_maxJumps = 20,
		_jumps = 1,
		
		_dashTimer = 0,
		
		HumanoidRootPart = humanoidRootPart,
		Humanoid = humanoid,
		Animator = humanoid:WaitForChild("Animator"),
		
		VectorForce = Instance.new("VectorForce", humanoidRootPart),
		
		JumpVelocity = 50,
		DashAcceleration = 800,
		DashCooldown = .5,
	},CharacterClient)
	self._jumps = self._maxJumps
	
	self.VectorForce.Attachment0 = humanoidRootPart.Attachment
	self.VectorForce.ApplyAtCenterOfMass = true
	self.VectorForce.Force = Vector3.new(0,0 * self:_getMass(),0)
	--self.VectorForce.Attachment0 = Instance.new("Attachment", humanoidRootPart)
	
	self._connections = {
		characterInstance.Destroying:Connect(function()
			self:Destroy()
		end),
		
		humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Landed then
				self._jumps = self._maxJumps
			end
		end),
	}
	
	return self
end

function CharacterClient:LoadAnimation()
	
end

function CharacterClient:Jump()
	if self._jumps <= 0 then return end
	if self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		self._jumps -= 1
	end
	local currentVelocity = self.HumanoidRootPart.AssemblyLinearVelocity
	self.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, self.JumpVelocity, currentVelocity.Z)
	self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

function CharacterClient:Dash()
	if tick() - self._dashTimer < self.DashCooldown then
		return
	end
	local dirVector = self.Humanoid.MoveDirection
	if dirVector.Magnitude == 0 then 
		dirVector = self.HumanoidRootPart.CFrame.LookVector
	end
	
	
	
	self.HumanoidRootPart.AssemblyLinearVelocity += dirVector * 100
	
	--local dashUpdate = game:GetService("RunService").RenderStepped:Connect(function(dt)
	--	self:_dashProcess(dt, dirVector)
	--end)
	
	--task.delay(self.DashCooldown, function()
	--	dashUpdate:Disconnect()
	--end)
	
	--self.VectorForce.Force = dirVector * self.DashAcceleration * self:_getMass()
	
	--self.VectorForce.Enabled = true
	--self.VectorForce.VectorForce = 
	--self.HumanoidRootPart:ApplyImpulse(dirVector * 1000)
	self._dashTimer = tick()
end

function CharacterClient:Destroy()
	_G.Character = nil
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	setmetatable(self, nil)
	table.clear(self)
end

return CharacterClient
