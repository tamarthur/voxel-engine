local ReplicatedStorage = game:GetService("ReplicatedStorage")

local INDEX_KEYS = {
	["FieldOfView"] = "_camera",
	["Parent"] = "_frame",
	["Position"] = "_frame",
	["Size"] = "_frame",
}

local Viewport = {}
Viewport.__index = function(self, key)
	local instance = INDEX_KEYS[key]
	if instance then
		return rawget(self, instance)[key]
	end
	return Viewport[key]
end

Viewport.__newindex = function(self, key, value)
	local instance = INDEX_KEYS[key]
	if instance then
		rawget(self, instance)[key] = value
		return
	end
	rawset(self, key, value)
end

--local function previewItem(viewport, model)
--	if not model then return end
--	model = model:Clone()
--	model.Parent = viewport
--	local size = model:GetModelSize()

--	local viewCamera = Instance.new("Camera",viewport)
--	viewCamera.FieldOfView = 0
--	viewport.CurrentCamera = viewCamera

--	local centerPos = model:GetModelCFrame().Position
--	local d = (size.Y / (math.tan(math.rad(viewCamera.FieldOfView / 2)) * 2)) --+ (size.Z / 4)

--	viewCamera.CFrame = CFrame.new(centerPos+model.Handle.CFrame.RightVector*d,centerPos) * CFrame.Angles(0,0,math.pi/4)
--end

function Viewport:_getModelDistanceFromCamera()
	return (self.Model.Y / (math.tan(math.rad(self._camera.FieldOfView / 2)) * 2)) --+ (size.Z / 4)
end

function Viewport:SetModel(model)
	if self.Model then
		self.Model:Destroy()
	end
	self.Model = model:Clone()
	self.Model.Parent = self._worldModel
end

function Viewport.new(parent, model)
	local frame = ReplicatedStorage.UI.Viewport:Clone()
	
	local self = setmetatable({
		_frame = frame,
		_worldModel = Instance.new("WorldModel", frame),
		_camera = Instance.new("Camera", frame)
	}, Viewport)
	
	if model then
		self:SetModel(model)
	end
	
	frame.Destroying:Connect(function()
		self:Destroy()
	end)
	frame.CurrentCamera = self._camera
	frame.Parent = parent
	
	return self
end

function Viewport:Enable()
	local size = self.Model:GetModelSize()
	local centerPos = self.Model:GetModelCFrame().Position
	local distance = (size.Y / (math.tan(math.rad(self._camera.FieldOfView / 2)) * 2)) --+ (size.Z / 6)
	self._camera.CFrame = CFrame.new(centerPos+self.Model.PrimaryPart.CFrame.RightVector*distance,centerPos) * CFrame.Angles(0,0,math.pi/4)
end

function Viewport:Disable()
	
end

function Viewport:Destroy()
	if self.Frame then
		self.Frame:Destroy()
	end
	setmetatable(self, nil)
end

return Viewport
