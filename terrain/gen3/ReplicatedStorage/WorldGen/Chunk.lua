local remotes = game.ReplicatedStorage.Remotes
local modules = game.ReplicatedStorage.Modules
local worldGen = game.ReplicatedStorage.WorldGen
local Brick = require(worldGen.Brick)
local BlockEnum = require(worldGen.BlockEnum)
local Config = require(worldGen.Config)
local Util = require(worldGen.Util)

local Chunk = {}
Chunk.__index = Chunk

function setNestedTable(list,...)
	local vars = {...}
	local curr = list
	for i,v in pairs(vars) do
		if type(v) == "table" then
			curr[v[1]] = v[2]
			break
		end
		if not curr[v] then
			curr[v] = {}
		end
		curr = curr[v]
	end
	return list
end

function bricking(grid)
	--task.desynchronize()
	local maxima = {}
	local currentRow = {}
	for row, colData in pairs(grid) do -- each row is 1 stack omving up
		local newRow = {}
		for col, levelData in pairs(colData) do--setting up current row stack
			local surfaceHeight = levelData[1]
			for level, blockType in pairs(levelData) do
				
				local prevLevel
				local prevBlockType
				if grid[row-1] and grid[row-1][col] and grid[row-1][col][level] then
					prevLevel = level
					prevBlockType = grid[row-1][col][level]
				end

				newRow = setNestedTable(newRow,blockType,level,{col,{}})
				maxima = setNestedTable(maxima,blockType,{level,{["Area"] = 0,}})

				if prevLevel and prevLevel == level and blockType == prevBlockType then
					newRow[blockType][level][col].Value = currentRow[blockType][level][col].Value + 1
				else
					newRow[blockType][level][col].Value = 1
				end
				
			end
		end
		
		currentRow = newRow
		
		for blockType, data in pairs(currentRow) do
			for level, data in pairs(data) do
				local largest = maxima[blockType][level]
				local max = {["Area"] = 0}
				for col, _ in pairs(data) do
					local length = data[col].Value
					local left = col
					local right = col

					while data[left-1] do
						if length <= data[left-1].Value then
							left -= 1
						else
							break
						end
					end
					while data[right+1] do
						if length <= data[right+1].Value then
							right += 1
						else
							break
						end
					end
					data[col].LeftOffset = left
					data[col].RightOffset = right
					local width = math.abs(right-left)+1
					local area = width*length
					if area > max.Area then
						max["Area"] = area
						max["Width"] = width
						max["Length"] = length
						max["X"] = row
						max["Z"] = right
						max["LBC"] = left
						max["UBC"] = right 
						max["LBR"] = row - length + 1
						max["UBR"] = row
					end
				end
				if max["Area"] > largest["Area"] then
					maxima[blockType][level] = max
					maxima[blockType][level]["Z"] = max.Z - max.Width/2
					maxima[blockType][level]["X"] = max.X - max.Length/2
				end 
			end
		end
	end
	--task.synchronize()
	return maxima
end

function Chunk.new(globalX,globalZ,data,partCache)
	local self = {
		X = globalX,
		Z = globalZ,
		_partCache = partCache,
		Loaded = false,
		_cancel = false,
		_data = data,
		_bricks = {}
	}

	return setmetatable(self,Chunk)
end

function Chunk:Load(renderTime)
	if self.Loaded or self._cancel then return end
	local function cancelCheck()
		if self._cancel then 
			self.Loaded = true
			coroutine.yield()
		end
	end

	local gridX = Util.ChunkToBlockGrid(self.X)
	local gridZ = Util.ChunkToBlockGrid(self.Z)
	repeat task.wait() until self._data ~= nil
	local chunkGrid = self._data
	
	local group = Instance.new("Model",workspace.Chunks)
	group.Name = gridX.."x"..gridZ
	
	local bricks = bricking(chunkGrid)
	while next(bricks) do
		for blockType, data in pairs(bricks) do
			for y, rectangle in pairs(data) do
				local x = gridX+(rectangle.X*Config.BlockSize)+Config.BlockSize/2
				local z = gridZ+(rectangle.Z*Config.BlockSize)+Config.BlockSize/2
				local pos = Vector3.new(x, y, z)
				local size = Vector3.new(rectangle.Length*Config.BlockSize,Config.BlockSize,rectangle.Width*Config.BlockSize)
				
				local brick = Brick.new(pos,size,blockType,self._partCache)
				--table.insert(self._bricks,brick)
				self._bricks[brick] = true
				
				for row = rectangle.LBR, rectangle.UBR do-- down up
					local chunkRow = chunkGrid[row]
					if not chunkRow then
						continue
					end
					for col = rectangle.LBC, rectangle.UBC do--right left
						local chunkCol = chunkRow[col]
						if not chunkCol then
							continue
						end
						if chunkCol then
							chunkCol[y] = nil
						end
						if not next(chunkCol) then
							chunkRow[col] = nil
						end
					end
					if not next(chunkRow) then
						chunkGrid[row] = nil
					end
				end
			end
		end
		task.wait(renderTime)
		if self._cancel then 
			self.Loaded = true
			return
		end
		bricks = bricking(chunkGrid)
	end
	self.Loaded = true
	for cache, _ in pairs(self._bricks) do
		cache:Load(group)
	end
end

function Chunk:Update(position,brick)
	
end

function Chunk:Unload()
	coroutine.wrap(function()
		self._cancel = true
		repeat task.wait() until self.Loaded
		
		for cache, _ in pairs(self._bricks) do
			cache:Unrender()
		end
		
		local i = 1
		for cache, _ in pairs(self._bricks) do
			cache:Unload()
			self._bricks[cache] = nil
			--cache.Color = Color3.new(1,1,1)
			--self._partCache:ReturnPart(cache)
			if i % Config.BlockSize == 0 then
				task.wait()
			end
			i += 1
		end
		self.Loaded = false
	end)()
end

return Chunk
