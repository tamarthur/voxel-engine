local HttpService = game:GetService("HttpService")

local Modules = game.ReplicatedStorage.Modules
local BlockData = require(Modules.Utility.BlockData)
local WorldConfig = require(Modules.Utility.WorldConfig)
local WorldBuilder = require(Modules.Utility.WorldBuilder)
local Tensor = require(Modules.Utility.Tensor)
local Remotes = game.ReplicatedStorage.Remotes

local BLOCK_RENDER_DELAY = WorldConfig.BLOCK_SIZE * WorldConfig.CHUNK_SIZE
local CHUNK_RENDER_DELAY = 100

local RENDER_DISTANCE = 10
local RENDER_RADIUS = math.floor(RENDER_DISTANCE/2)
--local PartCache = require(Modules.Utility.PartCache).new(script.Part, RENDER_DISTANCE^3)

--local Workers = require(Modules.Utility.Workers).new(8)
local Actors = {}
--table.insert(Actors, script.Actor)
for i = 1, 16 do
	local actor = script:WaitForChild("Actor"):Clone()
	actor.Parent = script.Parent
	table.insert(Actors, actor)
end

--local function GetActor()
--	local actor = workspace.Actors.Waiting:FindFirstChild("ActorClient")
--	if not actor then
--		workspace.Actors.Waiting.ChildAdded:Wait()
--		actor = workspace.Actors.Waiting.ActorClient
--	end
--	return actor
--end

local CurrentPosition = Vector3.zero
local PreviousPosition = Vector3.one

local ChunkGrid = {}

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

Humanoid.WalkSpeed = 100
HumanoidRootPart.Anchored = true

local gui = script.ScreenGui
gui.Frame.Render.Text = `Render: {RENDER_DISTANCE}`

gui.Frame["+"].MouseButton1Click:Connect(function() 
	RENDER_DISTANCE = math.clamp(RENDER_DISTANCE + 1, 2, 16)
	RENDER_RADIUS = math.floor(RENDER_DISTANCE/2)
	gui.Frame.Render.Text = `Render: {RENDER_DISTANCE}`
end)

gui.Frame["-"].MouseButton1Click:Connect(function()
	RENDER_DISTANCE = math.clamp(RENDER_DISTANCE - 1, 2, 16)
	RENDER_RADIUS = math.floor(RENDER_DISTANCE/2)
	gui.Frame.Render.Text = `Render: {RENDER_DISTANCE}`
end)

gui.Parent = Player:WaitForChild("PlayerGui")

local Visualizer = Instance.new("Part", workspace.FX)
Visualizer.Anchored = true
Visualizer.CanCollide = false
Visualizer.Transparency = 1
Visualizer.CastShadow = false
Visualizer.Locked = true
Visualizer.Size = WorldConfig.BLOCK_SIZE * WorldConfig.CHUNK_SIZE * Vector3.one

local Selection = Instance.new("SelectionBox", Visualizer)
Selection.Adornee = Visualizer

local function GetBricksInSpace(position, size, space)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {space}
	
	--local test = Instance.new("Part", workspace)
	--test.Anchored = true
	--test.CanCollide = false
	--test.Transparency = .5
	--test.Position = position
	--test.Size = size

	return workspace:GetPartBoundsInBox(CFrame.new(position), size, overlapParams)
end

local function CreateBrick(ID)
	local brick = Instance.new("Part")
	brick.Anchored = true
	brick.Size = WorldConfig.BLOCK_SIZE * Vector3.one
	brick.Color = BlockData[ID].Color--Color3.new(math.random(),math.random(),math.random())
	brick:SetAttribute("ID", ID)
	return brick
end

local function GreedyMesh(bricks)
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
			if not bricks[y][z][x-1] or not bricks[y][z][x] then continue end
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
				if not bricks[y][z-1][x] then continue end
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
				if not bricks[y-1][z][x] then continue end
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
end

local function LoadChunk(chunkKey, blocks)
	task.desynchronize()
	local cx, cy, cz = table.unpack(chunkKey:split(" "))
	--print(blocks)
	--exit()
	--print(blocks)
	debug.profilebegin("Initializing table")
	local bricks = {}
	for y = 1, WorldConfig.CHUNK_SIZE do
		bricks[y] = {}
		for z = 1, WorldConfig.CHUNK_SIZE do
			bricks[y][z] = {}
			--for x = 1, WorldConfig.CHUNK_SIZE do
			--	--local ID
			--	--if not pcall(function() 
			--	--	local yBlock = blocks[y] or blocks[tostring(y)]
			--	--	local zBlock = yBlock[z] or yBlock[tostring(z)]
			--	--	local xBlock = zBlock[x] or zBlock[tostring(x)]
			--	--	ID = xBlock
			--	--	end) then continue end
			--	--if not ID or ID == 0 or ID == 1 then continue end
			--	bricks[y][z][x] = {Size = Vector3.one, ID = ID}
			--end
		end
	end
	
	for _, blockData in pairs(blocks) do
		local x, y, z, blockID = table.unpack(blockData)
		if blockID == 1 then continue end
		bricks[y][z][x] = {Size = Vector3.one, ID = blockID}
	end
	
	debug.profileend()
	
	GreedyMesh(bricks)
	
	task.synchronize()
	debug.profilebegin("Create blocks")
	local chunkPosition = Vector3.new(cx, cy, cz)
	local count = 0
	WorldBuilder:ChunkIterate(bricks, function(y, z, x, brickData)
		count += 1
		if count % BLOCK_RENDER_DELAY == 0 then
			task.wait()
		end
		--local brick
		--brickData.Index = Vector3.new(x, y, z)
		
		local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), chunkPosition)
		local brick = CreateBrick(brickData.ID) --Instance.new("Part")--PartCache:GetPart()
		brick.Position = (blockPosition - brickData.Size/2) * WorldConfig.BLOCK_SIZE
		brick.Size = WorldConfig.BLOCK_SIZE*brickData.Size
		brick.Name = WorldBuilder:CoordinatesToKey(x, y, z)
		brick.Parent = workspace.Chunks[WorldBuilder:CoordinatesToKey(cx, cy, cz)]
		--print(brick)
	end)
	debug.profileend()
end

local function Compose(brick, chunk)
	local chunkPosition = Vector3.new(WorldBuilder:KeyToCoordinates(chunk.Name))
	
	local dim = 0
	for i = 3, 1, -1 do
		if brick.Size[WorldConfig.AXIS_MAP[i]] > 1 then
			dim = i
			break
		end
	end
	
	local halfChunkPosition = ((WorldConfig.CHUNK_SIZE * WorldConfig.BLOCK_SIZE)/2 - WorldConfig.BLOCK_SIZE/2) * Vector3.one -- 2*Vector3.one
	local chunkStudPosition = WorldBuilder:ChunkPositionToStudPosition(chunkPosition)
	local chunkUpperBound = chunkStudPosition + halfChunkPosition
	local chunkLowerBound = chunkStudPosition - halfChunkPosition

	for _, dir in pairs(WorldConfig.DIRECTION_MAP) do

		local absDir = WorldBuilder:ComponentOperation(math.abs, dir)
		local similarVector = Vector3.one - absDir
		
		--local searchSize = brick.Size + (4*Vector3.one - brick.Size) * absDir - 3*Vector3.one
		local searchPosition = brick.Position + (brick.Size/2)*dir + (WorldConfig.BLOCK_SIZE/2)*dir

		--local test = Instance.new("Part", workspace.FX.Folder)
		--test.Size = Vector3.one -- (Vector3.one - absDir) -- brick.Size * absDir + absDir  --(brick.Size + (4*Vector3.one - brick.Size) * dir)/4
		--test.Position = searchPosition
		--test.Anchored = true
		
		if searchPosition.X > chunkUpperBound.X or searchPosition.X < chunkLowerBound.X or 
			searchPosition.Y > chunkUpperBound.Y or searchPosition.Y < chunkLowerBound.Y or
			searchPosition.Z > chunkUpperBound.Z or searchPosition.Z < chunkLowerBound.Z then
			continue
		end
		
		--print(test.Size)
		
		for _, adjacentBrick in pairs(GetBricksInSpace(searchPosition, Vector3.one, chunk)) do
			--local Selection = Instance.new("SelectionBox", adjacentBrick)
			--Selection.Adornee = adjacentBrick
			if brick:GetAttribute("ID") ~= adjacentBrick:GetAttribute("ID") then
				continue
			end
			
			local similarSize = brick.Size * similarVector
			if adjacentBrick.Size * similarVector ~= similarSize then
				continue
			end
	
			if adjacentBrick.Position * similarVector ~= brick.Position * similarVector then
				continue
			end
			
			local combinedSize = similarSize + (adjacentBrick.Size + brick.Size) * absDir
			local combinedPosition = brick.Position + (combinedSize - brick.Size)/2 * dir

			adjacentBrick.Position = combinedPosition
			adjacentBrick.Size = combinedSize
			
		 	pcall(function()	brick:Destroy() end)

			return Compose(adjacentBrick, chunk)
			
		end
		
	end
end

local function Decompose(brick, studPosition, chunk, dim, products)
	local axis = WorldConfig.AXIS_MAP[dim]
	if not pcall(function()
		if brick.Size[axis] <= 1 then
			
		end
		end) then
		print(dim)
		print(brick)
		--brick.Transparency = .5
		print(axis)
	end
	if brick.Size[axis] <= 1 then
		return Decompose(brick, studPosition, chunk, dim - 1, products)
	end

	local axisVector = Vector3[axis.."Axis"]
	local startingIndex = brick.Position[axis] - brick.Size[axis]/2
	
	local lowerSize = studPosition[axis] - startingIndex - WorldConfig.BLOCK_SIZE/2
	if lowerSize > 0 then
		local lowerSlice = CreateBrick(brick:GetAttribute("ID"))
		lowerSlice.Size = brick.Size + (lowerSize - brick.Size[axis]) * axisVector
		lowerSlice.Position = brick.Position + (startingIndex + lowerSize/2 - brick.Position[axis]) * axisVector
		lowerSlice.Parent = chunk
		table.insert(products, lowerSlice)
	end
	
	local upperSize = brick.Size[axis] - lowerSize - WorldConfig.BLOCK_SIZE
	if upperSize > 0 then
		local upperSlice = CreateBrick(brick:GetAttribute("ID"))
		upperSlice.Size = brick.Size + (upperSize - brick.Size[axis]) * axisVector
		upperSlice.Position = brick.Position + (studPosition[axis] + WorldConfig.BLOCK_SIZE/2 + upperSize/2 - brick.Position[axis]) * axisVector
		upperSlice.Parent = chunk
		table.insert(products, upperSlice)
	end
	
	if dim == 1 then brick:Destroy() return products end
	
	local slice = brick--CreateBrick()
	slice.Position = brick.Position + (studPosition[axis] - brick.Position[axis]) * axisVector
	slice.Size = brick.Size + (WorldConfig.BLOCK_SIZE - brick.Size[axis]) * axisVector

	return Decompose(slice, studPosition, chunk, dim - 1, products)
end

--local function Decompose(brick, blockIndex, chunkPosition, dim, products)
--	--if not dim then dim = 3 end
--	--if not products then products = {} end
--	--local brickIndex = WorldBuilder:StudPositionToBlockIndex((brick.Position + brick.Size/2) - 2*Vector3.one, chunkPosition)
--	local brickData = {
--		Index = Vector3.new(WorldBuilder:KeyToCoordinates(brick.Name)), 
--		Size = brick.Size/WorldConfig.BLOCK_SIZE, 
--		ID = brick:GetAttribute("ID")
--	}
--	local axis = WorldConfig.AXIS_MAP[dim]

--	if brick.Size[axis] <= 1 then
--		return Decompose(brick, blockIndex, chunkPosition, dim - 1)
--	end

--	local lowerIndex = blockIndex[axis] - 1
--	local lowerSize = brickData.Size[axis] - brickData.Index[axis] + lowerIndex
--	if lowerSize > 0 then
--		local lowerSliceData = {
--			Index = brickData.Index + (lowerIndex - brickData.Index[axis]) * Vector3[axis.."Axis"],
--			Size = brickData.Size + (lowerSize - brickData.Size[axis]) * Vector3[axis.."Axis"],
--			ID = brickData.ID
--		}
--		table.insert(products, CreateBrick(lowerSliceData, chunkPosition))
--	end

--	local upperSize = brickData.Index[axis] - blockIndex[axis]
--	if upperSize > 0 then
--		local upperSliceData = {
--			Index = brickData.Index, 
--			Size = brickData.Size + (upperSize - brickData.Size[axis]) * Vector3[axis.."Axis"],
--			ID = brickData.ID
--		}
--		brick.Position = GetBrickPosition(WorldBuilder:BlockIndexToBlockPosition(upperSliceData.Index, chunkPosition), upperSliceData.Size)
--		brick.Size = WorldConfig.BLOCK_SIZE * upperSliceData.Size
--		table.insert(products, brick)
--	else
--		brick:Destroy()
--	end
	
--	if dim == 1 then return products end
	
--	local sliceData = {
--		Index = brickData.Index + (blockIndex[axis] - brickData.Index[axis]) * Vector3[axis.."Axis"],
--		Size = brickData.Size + (1 - brickData.Size[axis]) * Vector3[axis.."Axis"],
--		ID = brickData.ID
--	}
--	return Decompose(CreateBrick(sliceData, chunkPosition), blockIndex, chunkPosition, dim - 1, products)
--end

local function OnUpdate(changes)
	print("start")
	Player:SetAttribute("Updating", true)
	local updated = {}
	for _, change in pairs(changes) do
		local cx, cy, cz, x, y, z, blockID = table.unpack(change)
		
		--print(blockID)
		
		local chunkKey = WorldBuilder:CoordinatesToKey(cx, cy, cz)
		local chunk = workspace.Chunks:FindFirstChild(chunkKey)
		
		if not chunk then
			--if (CurrentPosition - Vector3.new(cx, cy, cz)).Magnitude > RENDER_DISTANCE then
			--	continue
			--end
			
			--local folder = Instance.new("Folder")
			--folder.Name = chunkKey
			--folder.Parent = workspace.Chunks
			--chunk = folder
			continue
		end
		
		
		local blockIndex = Vector3.new(x, y, z)
		local chunkPosition = Vector3.new(cx, cy, cz)
		--print(blockIndex)
		local function UpdateBlock()
			if not blockID then
				local studPosition = WorldBuilder:BlockPositionToStudPosition(blockIndex, chunkPosition)
				local brick = GetBricksInSpace(studPosition, Vector3.one, chunk)[1]
				
				--local products = Decompose(brick, blockIndex, chunkPosition, 3, {}) --Decompose(brick, studPosition, chunk, 3, {})
				local products = Decompose(brick, studPosition, chunk, 3, {})

				for i = #products, 1, -1 do
					--local product = products[i]
					--if not product then continue end
					--Compose(product, chunk)
					table.insert(updated, {products[i], chunk})
				end
				return
			end

			local block = CreateBrick(blockID)
			block.Size = WorldConfig.BLOCK_SIZE * Vector3.one
			block.Position = WorldBuilder:BlockIndexToStudPosition(Vector3.new(x, y, z), Vector3.new(cx, cy, cz))
			block.Parent = chunk
			table.insert(updated, {block, chunk})
		end
		
		if not chunk:GetAttribute("Loaded") then
			coroutine.wrap(function()
				chunk:GetAttributeChangedSignal("Loaded"):Wait()
				UpdateBlock()
			end)()
			continue
		end
		
		UpdateBlock()
	end
	
	for _, data in pairs(updated) do
		local brick, chunk = table.unpack(data)
		if not brick then continue end
		Compose(brick, chunk)
	end
	Player:SetAttribute("Updating", nil)
end

local function Render()
	CurrentPosition = WorldBuilder:StudPositionToChunkPosition(HumanoidRootPart.Position)
	if CurrentPosition == PreviousPosition then return end

	print("Chunk Position:", CurrentPosition)
	Visualizer.Position = WorldBuilder:ChunkPositionToStudPosition(CurrentPosition)

	local inRange = {}
	local loadData = {}

	for cx = CurrentPosition.X - RENDER_RADIUS, CurrentPosition.X + RENDER_RADIUS do
		for cy = CurrentPosition.Y - RENDER_RADIUS, CurrentPosition.Y + RENDER_RADIUS do
			for cz = CurrentPosition.Z - RENDER_RADIUS, CurrentPosition.Z + RENDER_RADIUS do

				local chunkKey = WorldBuilder:CoordinatesToKey(cx, cy, cz)
				local chunk = workspace.Chunks:FindFirstChild(chunkKey)

				if (Vector3.new(cx, cy, cz) - CurrentPosition).Magnitude < RENDER_RADIUS then

					if not chunk then
						local chunkFolder = Instance.new("Folder", workspace.Chunks)
						chunkFolder.Name = chunkKey
						table.insert(loadData, chunkKey)
					end

					inRange[chunkKey] = true
				end

			end
		end
	end

	for _, chunk in pairs(workspace.Chunks:GetChildren()) do
		if not inRange[chunk.Name] then
			ChunkGrid[chunk.Name] = nil
			--UnloadChunk(chunk.Name, chunk:GetChildren())
			chunk:Destroy()
		end
	end	
	
	--local a = {{1,44},{2, 62}, {2, 22}, {2, 5432}}
	
	--table.sort(a, function(a,b)
	--	return a[2] < b[2]
	--end)
	
	--print(a)
	
	local chunks = Remotes.GetChunks:InvokeServer(loadData)
	
	table.sort(chunks, function(a, b)
		local posA = Vector3.new(WorldBuilder:KeyToCoordinates(a[1]))
		local posB = Vector3.new(WorldBuilder:KeyToCoordinates(b[1]))
		return (CurrentPosition - posA).Magnitude < (CurrentPosition - posB).Magnitude
	end)
	
	local count = 1
	for _, chunkData in pairs(chunks) do
		--local chunkKey, blocks = table.unpack(chunkData)
		--Workers:DoWork(LoadChunk, table.unpack(chunkData))
		--local actor = GetActor()
		--print(actor)
		--actor:SendMessage("DoWork", LoadChunk, table.unpack(chunkData))
		--print(Actors[count])
		Actors[count]:SendMessage("LoadChunk", table.unpack(chunkData))
		--LoadChunk(chunkKey, blocks)
		--ChunkGrid[chunkKey] = blocks
		count = count % 8 + 1
		if count == 8 then
			task.wait()
		end
		--print(blocks)
		--workspace.Chunks[chunkKey]:SetAttribute("Loaded", true)
		--task.wait()
		--if count % CHUNK_RENDER_DELAY == 0 then
		--	task.wait()
		--end
	end
	--print(count)
	--coroutine.wrap(function()
	--end)()

	PreviousPosition = CurrentPosition
end

Remotes.Update.OnClientEvent:Connect(OnUpdate)
script.Event.Event:Connect(function(cx, cy, cz, x, y, z)
	local chunk = ChunkGrid[WorldBuilder:CoordinatesToKey(cx, cy, cz)]
	local ID
	pcall(function() 
		local yBlock = chunk[y] or chunk[tostring(y)]
		local zBlock = yBlock[z] or yBlock[tostring(z)]
		local xBlock = zBlock[x] or zBlock[tostring(x)]
		ID = xBlock
	end)
	print(ID and BlockData[ID].Name or "nil", x, y, z)
	print(chunk)
end)

Render()
HumanoidRootPart.Anchored = false

while true do
	Render()
	task.wait(.1)
	local pos = WorldBuilder:ComponentOperation(math.floor, WorldBuilder:MapPositionToGrid(HumanoidRootPart.Position)/WorldConfig.BLOCK_SIZE)
	local x, y, z = WorldBuilder:GetComponents(pos)
	gui.Frame.X.Text = `X: {x}`
	gui.Frame.Y.Text = `Y: {y}`
	gui.Frame.Z.Text = `Z: {z}`
end
