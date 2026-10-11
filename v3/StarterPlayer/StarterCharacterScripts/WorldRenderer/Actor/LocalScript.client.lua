local actor = script:GetActor()

local Modules = game.ReplicatedStorage.Modules
local Tensor = require(Modules.Utility.Tensor)
local WorldConfig = require(Modules.Utility.WorldConfig)
local WorldBuilder = require(Modules.Utility.WorldBuilder)
local BlockData = require(Modules.Utility.BlockData)

local function CreateBrick(ID)
	local brick = Instance.new("Part")
	brick.Anchored = true
	brick.Size = WorldConfig.BLOCK_SIZE * Vector3.one
	brick.Color = BlockData[ID].Color--Color3.new(math.random(),math.random(),math.random())
	brick:SetAttribute("ID", ID)
	return brick
end

actor:BindToMessage("LoadChunk", function(chunkKey, blocks)
	task.desynchronize()
	local cx, cy, cz = table.unpack(chunkKey:split(" "))
	--print(blocks)
	--exit()
	--print(blocks)
	debug.profilebegin("Initializing table")
	local bricks = Tensor.new(3)
	--for y = 1, WorldConfig.CHUNK_SIZE do
	--	bricks[y] = {}
	--	for z = 1, WorldConfig.CHUNK_SIZE do
	--		bricks[y][z] = {}
	--		--for x = 1, WorldConfig.CHUNK_SIZE do
	--		--	--local ID
	--		--	--if not pcall(function() 
	--		--	--	local yBlock = blocks[y] or blocks[tostring(y)]
	--		--	--	local zBlock = yBlock[z] or yBlock[tostring(z)]
	--		--	--	local xBlock = zBlock[x] or zBlock[tostring(x)]
	--		--	--	ID = xBlock
	--		--	--	end) then continue end
	--		--	--if not ID or ID == 0 or ID == 1 then continue end
	--		--	bricks[y][z][x] = {Size = Vector3.one, ID = ID}
	--		--end
	--	end
	--end

	for _, blockData in pairs(blocks) do
		local x, y, z, blockID = table.unpack(blockData)
		if blockID == 1 then continue end
		bricks[y][z][x] = {Size = Vector3.one, ID = blockID}
	end

	debug.profileend()

	--local function combineColumn(y)
	--	for z = 2, WorldConfig.CHUNK_SIZE do
	--		combineRow(y, z)
	--		for x, brick in pairs(bricks[y][z]) do	
	--			if not bricks[y][z-1][x] then continue end
	--			if brick.ID ~= bricks[y][z-1][x].ID then continue end
	--			if brick.Size.X ~= bricks[y][z-1][x].Size.X then continue end
	--			brick.Size += Vector3.new(0, 0, bricks[y][z-1][x].Size.Z)
	--			bricks[y][z-1][x] = nil
	--		end
	--	end
	--end
	debug.profilebegin("Greedy meshing")
	local function combineRows(y, z)
		for x = 2, WorldConfig.CHUNK_SIZE do
			if not bricks:Get(y, z, x-1) or not bricks:Get(y, z, x) then continue end
			if bricks[y][z][x].ID ~= bricks[y][z][x-1].ID then continue end
			bricks[y][z][x].Size += Vector3.new(bricks[y][z][x-1].Size.X, 0, 0)
			bricks[y][z][x-1] = nil
		end
	end
	local function combinePlanes(y)
		combineRows(y, 1)
		for z = 2, WorldConfig.CHUNK_SIZE do
			combineRows(y, z)
			for x, brick in pairs(bricks[y][z]) do	
				if not bricks:Get(y, z-1, x) then continue end
				if brick.ID ~= bricks[y][z-1][x].ID then continue end
				if brick.Size.X ~= bricks[y][z-1][x].Size.X then continue end
				brick.Size += Vector3.new(0, 0, bricks[y][z-1][x].Size.Z)
				bricks[y][z-1][x] = nil
			end
		end
	end
	combinePlanes(1)
	for y = 2, WorldConfig.CHUNK_SIZE do
		combinePlanes(y)
		for z, _ in pairs(bricks[y]) do
			for x, brick in pairs(_) do				
				if not bricks:Get(y-1, z, x) then continue end
				if brick.ID ~= bricks[y-1][z][x].ID then continue end
				if brick.Size.X ~= bricks[y-1][z][x].Size.X then continue end
				if brick.Size.Z ~= bricks[y-1][z][x].Size.Z then continue end
				brick.Size += Vector3.new(0, bricks[y-1][z][x].Size.Y, 0)
				bricks[y-1][z][x] = nil
			end
		end
	end
	--task.wait()
	debug.profileend()
	--for y = 1, WorldConfig.CHUNK_SIZE do
	--	--joining n
	--	for z = 1, WorldConfig.CHUNK_SIZE do
	--		for x = 2, WorldConfig.CHUNK_SIZE do
	--			if not bricks[y][z][x-1] or not bricks[y][z][x] then continue end
	--			if bricks[y][z][x].ID ~= bricks[y][z][x-1].ID then continue end
	--			bricks[y][z][x].Size += Vector3.new(bricks[y][z][x-1].Size.X, 0, 0)
	--			bricks[y][z][x-1] = nil

	--		end
	--	end

	--	--joining n^2
	--	for z = 2, WorldConfig.CHUNK_SIZE do
	--		for x, brick in pairs(bricks[y][z]) do	
	--			if not bricks[y][z-1][x] then continue end
	--			if brick.ID ~= bricks[y][z-1][x].ID then continue end
	--			if brick.Size.X ~= bricks[y][z-1][x].Size.X then continue end
	--			brick.Size += Vector3.new(0, 0, bricks[y][z-1][x].Size.Z)
	--			bricks[y][z-1][x] = nil
	--		end
	--	end
	--end
	----joining n^3
	--for y = 2, WorldConfig.CHUNK_SIZE do
	--	for z, _ in pairs(bricks[y]) do
	--		for x, brick in pairs(_) do				
	--			if not bricks[y-1][z][x] then continue end
	--			if brick.ID ~= bricks[y-1][z][x].ID then continue end
	--			if brick.Size.X ~= bricks[y-1][z][x].Size.X then continue end
	--			if brick.Size.Z ~= bricks[y-1][z][x].Size.Z then continue end
	--			brick.Size += Vector3.new(0, bricks[y-1][z][x].Size.Y, 0)
	--			bricks[y-1][z][x] = nil
	--		end
	--	end
	--end
	task.synchronize()
	debug.profilebegin("Create blocks")
	local chunkPosition = Vector3.new(cx, cy, cz)
	local count = 0
	WorldBuilder:ChunkIterate(bricks, function(y, z, x, brickData)
		count += 1
		if count % 4 == 0 then
			task.wait()
		end
		--local brick
		--brickData.Index = Vector3.new(x, y, z)

		local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), chunkPosition)
		local brick = CreateBrick(brickData.ID) --Instance.new("Part")--PartCache:GetPart()
		brick.Position = (blockPosition - brickData.Size/2) * WorldConfig.BLOCK_SIZE
		brick.Size = WorldConfig.BLOCK_SIZE*brickData.Size
		brick.Name = WorldBuilder:CoordinatesToKey(x, y, z)
		local chunk = workspace.Chunks[WorldBuilder:CoordinatesToKey(cx, cy, cz)]
		brick.Parent = chunk
		chunk:SetAttribute("Loaded", true)
		--print(brick)
	end)
	debug.profileend()
end)
