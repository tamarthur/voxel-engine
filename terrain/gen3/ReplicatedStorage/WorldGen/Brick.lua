local worldGen = game.ReplicatedStorage.WorldGen
local BlockEnum = require(worldGen.BlockEnum)
local Config = require(worldGen.Config)
local Brick = {}
Brick.__index = Brick

function Brick.new(position, size, id, partCache)
	return setmetatable({
		ID = id,
		Position = position,
		Size = size,
		_partCache = partCache,
		_object = {},
	},Brick)
end

function Brick:Load(group)
	group = group or workspace.Chunks
	if self.ID == BlockEnum.Grass then
		local grass = self._partCache:GetPart()
		grass.Position = self.Position+Vector3.new(0,1.6,0)
		grass.Size = self.Size-Vector3.new(0,3.2,0)
		grass.Color = Config.ColorMap[BlockEnum[self.ID]]
		grass.Material = Config.MaterialMap[BlockEnum[self.ID]]
		grass.Parent = group

		local dirt = self._partCache:GetPart()
		dirt.Position = self.Position-Vector3.new(0,.4,0)
		dirt.Size = self.Size-Vector3.new(0,.8,0)
		dirt.Color = Config.ColorMap.Dirt
		dirt.Material = Config.MaterialMap.Dirt
		dirt.Parent = group
		
		table.insert(self._object,dirt)
		table.insert(self._object,grass)
	else
		local part = self._partCache:GetPart()
		part.Size = self.Size
		part.Position = self.Position
		part.Color = Config.ColorMap[BlockEnum[self.ID]]
		part.Material = Config.MaterialMap[BlockEnum[self.ID]]
		part.Parent = group
		table.insert(self._object,part)
	end
	
	for i,v in pairs(self._object) do
		v.Transparency = 0
	end
end

function Brick:Split(pos)
	local xSize = self.Length-1
	local left = {
		Width = self.Width,
		Length = xSize,
	}
end

function Brick:Unrender()
	for i,v in pairs(self._object) do
		v.Transparency = 1
	end
end

function Brick:Unload()
	for i,v in pairs(self._object) do
		self._partCache:ReturnPart(v)
		self._object[i] = nil
	end
end

function Brick:Destroy()
	self:Unload()
end

return Brick
