local TerrainModules = game.ReplicatedStorage.Modules.Terrain

local WorldConfig = require(TerrainModules.WorldConfig)
local WorldUtil = require(TerrainModules.WorldUtil)
local BlockEnum = require(TerrainModules.BlockEnum)

local Chunk = {}
Chunk.__index = Chunk

local function greedyMesh()
	
end

function maximalRectangle(grid)
	if not next(grid) then return end
	local m, n = 16, 16
	local maxA = 0
	local maxX1, maxY1, maxX2, maxY2, maxL, maxH

	local layer = table.create(n,0)
	for i = 1, m do
		for j = 1, n do
			if grid[i.." "..j] then
				layer[j] += 1
			else
				layer[j] = 0
			end
		end

		local stack = {}
		local left, height, length

		local function loop(j)
			height = layer[table.remove(stack,#stack)]
			if not next(stack) then
				left = 0
			else
				left = stack[#stack]
			end
			length = j - left
			local area = height * length
			if area > maxA then
				maxA = area
				maxX1 = left + 1
				maxX2 = j
				maxY2 = i
				maxH = height
				maxL = length
			end
		end

		for j = 1, n do
			while next(stack) and layer[stack[#stack]] > layer[j] do
				loop(j-1)
			end
			table.insert(stack,j)
		end

		while next(stack) do
			loop(n)
		end
		--print(layer)
		--print(maxX1, maxX2, maxY1, maxY2, maxL, maxH,maxA)
	end
	maxY1 = maxY2 - maxH + 1

	--print(maxA)
	return {maxX1, maxX2, maxY1, maxY2, maxL, maxH}
end

function Chunk.new(x, y, z, data)
	local self = setmetatable({}, Chunk)
	self.X = x
	self.Y = y
	self.Z = z
	self.Data = data
	self.Bricks = {}
	return self
end

function Chunk:Load(data)
	if data then
		self.Data = data
	end
	
	for position, ID in pairs(data) do
		local x, y, z = table.unpack(position:split(" "))
		local brick = _G.ClientStorage.PartCache:GetPart()
		brick.Transparency = 0
		brick.Position = Vector3.new(WorldUtil.getWorldPosition(self.X, self.Y, self.Z, x, y, z))
		brick.Color = BlockEnum.fromID[ID or 1].Color or Color3.new()
		table.insert(self.Bricks, brick)
	end
	
	--for y = 1, WorldConfig.CHUNK_SIZE do
	--	for x = 1, WorldConfig.CHUNK_SIZE do
	--		for z = 1, WorldConfig.CHUNK_SIZE do
	--			local block = data[WorldUtil.stringify(x, y, z)]
	--		end
	--	end
	--end
	
	self.Loaded = true
end

function Chunk:Unload()
	for i, brick in pairs(self.Bricks) do
		brick.Transparency = 1
		_G.ClientStorage.PartCache:ReturnPart(brick)
		if i % 4 == 0 then
			task.wait()
		end
	end
	self.Loaded = nil
end

function Chunk:Destroy()
	
end

return Chunk
