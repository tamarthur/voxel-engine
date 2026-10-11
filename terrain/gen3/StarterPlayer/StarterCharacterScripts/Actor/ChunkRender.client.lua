local worldGen = game.ReplicatedStorage.WorldGen
local modules = game.ReplicatedStorage.Modules

local PartCache = require(modules.PartCache)
local Encode = require(modules.Encode)
local BlockEnum = require(worldGen.BlockEnum)
local Config = require(worldGen.Config)
local Util = require(worldGen.Util)
local remotes = game.ReplicatedStorage.Remotes

local camera = workspace.CurrentCamera

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
humanoidRootPart.Anchored = true

local renderDistance = 12
local renderRadius = math.floor(renderDistance/2)

local Chunk = require(game.ReplicatedStorage.WorldGen.Chunk)
local partCache = PartCache.new(game.ReplicatedStorage.Block,Config.ChunkSize*renderDistance, workspace.Cache)
local chunkGrid = {}
local prevPos = {X=0,Z=0}

--repeat wait() until #workspace.Chunks:GetChildren() >= renderDistance^2
humanoidRootPart.Anchored = false

function distance(p1,p2)
	local x1 = p1[1]
	local z1 = p1[2]
	local x2 = p2[1]
	local z2 = p2[2]
	return ((x2-x1)^2+(z2-z1)^2)^.5
end

function loadRenderDistance(cx,cz)
	local sendData = {}
	local xn = renderRadius + cx
	local zn = renderRadius + cz
	for x = -renderRadius + cx, renderRadius + cx do
		for z = -renderRadius + cz, renderRadius + cz do
			if distance({cx,cz},{x,z}) < renderRadius then
				if not chunkGrid[x] then
					chunkGrid[x] = {}
				end
				if chunkGrid[x][z] then
					continue
				end
				chunkGrid[x][z] = -1
				table.insert(sendData,{x,z})
			end
		end
	end
	--sendData = Encode.compress(sendData)
	remotes.GetChunk:FireServer(sendData)
end

function unloadRenderDistance(cx,cz)
	for x, row in pairs(chunkGrid) do
		for z, _ in pairs(row) do
			if distance({cx,cz},{x,z}) > renderRadius then
				if not chunkGrid[x][z] then
					continue
				end
				if chunkGrid[x][z] == -1 then--Loading
					continue
				end
				chunkGrid[x][z]:Unload()
				chunkGrid[x][z] = nil
			end
		end
	end
end

loadRenderDistance(0,0)

function globalToGridPosition(x,z)
	return math.floor(x/64), math.floor(z/64)--/block_size^3
end

remotes.GetChunk.OnClientEvent:Connect(function(gridData)
	--gridData = Encode.decompress(gridData)
	for _, data in pairs(gridData) do
		local x = data[1]
		local z = data[2]
		local chunkData = data[3]
		if not chunkGrid[x] then
			chunkGrid[x] = {}
		end
		local chunk = Chunk.new(x,z,chunkData,partCache)
		coroutine.wrap(chunk.Load)(chunk,math.clamp(math.log10(renderDistance-3)/18,0,2))
		chunkGrid[x][z] = chunk
		task.wait()
	end
end)

player:GetAttributeChangedSignal("RenderDistance"):Connect(function()
	humanoidRootPart.Anchored = true
	renderDistance = player:GetAttribute("RenderDistance")
	renderRadius = math.floor(renderDistance/2)
	loadRenderDistance(globalToGridPosition(humanoidRootPart.Position.X,humanoidRootPart.Position.Z))
	unloadRenderDistance(prevPos.X,prevPos.Z)
	task.wait(1)
	humanoidRootPart.Anchored = false
end)

game:GetService("RunService").RenderStepped:ConnectParallel(function()
	local xPos, zPos = globalToGridPosition(humanoidRootPart.Position.X,humanoidRootPart.Position.Z)
	
	if prevPos["X"] == xPos and prevPos["Z"] == zPos then
		return
	end

	local currentPos = {
		X = xPos,
		Z = zPos,
	}
	
	local diffX = currentPos.X-prevPos.X
	local diffZ = currentPos.Z-prevPos.Z
	print(diffX,diffZ)
	
	task.synchronize()
	
	loadRenderDistance(xPos,zPos)
	unloadRenderDistance(prevPos.X,prevPos.Z)

	prevPos = currentPos
	
	--remotes.GetChunk:FireServer(sendData)
	--remotes.GetChunk:FireServer(Encode.compress(game:GetService("HttpService"):JSONEncode(sendData)))
end)
