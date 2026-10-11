local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local sharedData = ReplicatedStorage.SharedData

local InstanceWrapper = require(modules.InstanceWrapper)
local ClientStorage = require(sharedData.ClientStorage)

local BlockEnum = require(modules.BlockEnum)
local BlockConfig = require(modules.BlockConfig)

local Brick = {}
Brick.__index = Brick

function Brick.new(position, size, id)
	local self = setmetatable({_instance = ClientStorage.PartCache:GetPart()},Brick)
	self._instance.Transparency = 1
	self._instance.Position = position
	self._instance.Size = size
	self.ID = id
	
	self._instance.Material = BlockConfig.MaterialMap[self.ID]
	self._instance.Color = BlockConfig.ColorMap[self.ID]
	return self
end

function Brick:Load(group)
	if group then
		self.Parent = group
	end
	--print(self.ID, type(self.ID))
	--for i,v in pairs(BlockConfig.MaterialMap) do
	--	print(i,v,type(i),type(v))
	--end
	--print(BlockConfig.MaterialMap[self.ID],self.ID,BlockConfig.MaterialMap)
	self._instance.Transparency = 0
end

function Brick:Split(pos)
	local x1 = pos.X + 4
	local x2 = self._instance.Size.X/2 - 2
	
	Brick.new(Vector3.new(x2-x1, pos.Y, pos.Z), Vector3.new())
	
	for x = pos.X, self._instance.Size.X/2 do
		
	end
	
end

function Brick:Unrender()
	self._instance.Transparency = 1
end

function Brick:Unload()
	ClientStorage.PartCache:ReturnPart(self._instance)
end

return Brick
