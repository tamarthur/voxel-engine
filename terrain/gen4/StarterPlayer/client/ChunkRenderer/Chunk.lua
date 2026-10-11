local Chunk = {}
Chunk.__index = Chunk

local ReplicatedStorage = game.ReplicatedStorage
local modules = ReplicatedStorage.Modules

local Signal = require(modules.Signal)

local Brick = require(script.Parent.Brick)
local BlockConfig = require(modules.BlockConfig)

function BlockToChunkGrid(x)
	return x/BlockConfig.BlockSize*BlockConfig.ChunkSize
end

function ChunkToBlockGrid(x)
	return x*BlockConfig.BlockSize*BlockConfig.ChunkSize
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

function Chunk.new(cx,cz,data)
	local self = setmetatable({},Chunk)
	self.cx = cx
	self.cz = cz
	self._bricks = {}
	return self
end

function ChunkLoad(self, data, renderDelay)
	self.Data = data

	for y, blocks in pairs(data) do
		--if y ~= "-16" then continue end
		for blockID, grid in pairs(blocks) do
			local rectData = maximalRectangle(grid)
			while rectData do
				local x1, x2, y1, y2, l, w = table.unpack(rectData)
				if self._cancel then  
					self.Loaded = true
					return
				end
				--print(x1, x2, y1, y2, l, w)
				--print("LB: "..rectLeft,"RB: "..rectRight,"TOP: "..rectTop,"BOTTOM: "..rectBottom,"HEIGHT "..rectWidth,"Y "..y)
				--print(grid)
				for x = y1, y2 do
					for z = x1, x2 do
						grid[x.." "..z] = nil
					end
				end
				--print("afer removin")
				--print(grid)

				local rectPosX = x1 + l/2
				local rectPosZ = y1 + w/2

				local globalRectX = 64*self.cx + 4 * rectPosX - BlockConfig.ChunkSize
				local globalRectZ = 64*self.cz + 4 * rectPosZ - BlockConfig.ChunkSize

				local brick = Brick.new(Vector3.new(globalRectX,y,globalRectZ),Vector3.new(4*l,4,4*w),tonumber(blockID))
				table.insert(self._bricks,brick)

				rectData = maximalRectangle(grid)
			end

		end
		task.wait(renderDelay)
	end
	for _, brick in pairs(self._bricks) do
		if self._cancel then  
			self.Loaded = true
			return
		end
		brick:Load(workspace.Chunks)
	end
	self.Loaded = true

end

function Chunk:Load(...)
	coroutine.wrap(ChunkLoad)(self, ...)
end

function Chunk:Unrender()
	
end


function Chunk:Update(brickInstance, pos)
	local brick = self._bricks[brickInstance]
	if brick then
		brick:Split(pos)
	end
end

function Chunk:Unload()
	self._cancel = true
	if not self.Loaded then
		repeat task.wait() until self.Loaded
	end
	for _, brick in pairs(self._bricks) do
		brick:Unrender()
	end
	for i, brick in pairs(self._bricks) do
		brick:Unload()
		self._bricks[i] = nil
		if i % BlockConfig.BlockSize == 0 then
			task.wait()
		end
	end
	--self._folder:Destroy()
end

return Chunk
