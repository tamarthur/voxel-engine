local ChunkRenderer = {}
ChunkRenderer.__index = ChunkRenderer

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game.ReplicatedStorage

local sharedData = ReplicatedStorage.SharedData
local modules = ReplicatedStorage.Modules
local remotes = ReplicatedStorage.Remotes

local base93 = require(modules.base93)

local BlockConfig = require(modules.BlockConfig)
local Chunk = require(script.Chunk)
local PartCache = require(modules.PartCache)
local ClientStorage = require(sharedData.ClientStorage)

function distance(p1,p2)
	return math.sqrt( math.pow(p2[1]-p1[1], 2) + math.pow(p2[2]-p1[2], 2) )
end

function getChunkPosition(character)
	local position = character:WaitForChild("HumanoidRootPart").Position
	local x = math.floor(position.X/64 + .5)
	local z = math.floor(position.Z/64 + .5)
	return x,z
end

function ChunkRenderer.Init(character,renderDistance)
	local renderDistance = 16
	ClientStorage.PartCache = PartCache.new(game.ReplicatedStorage.Block,BlockConfig.ChunkSize*renderDistance, workspace.Cache)
	ChunkRenderer.renderDistance = renderDistance
	ChunkRenderer.Grid = {}
	ChunkRenderer.PreviousPosition = {}
	
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	
	ChunkRenderer.renderSteppedEvent = RunService.RenderStepped:Connect(function()
		local cx, cz = getChunkPosition(character)
		local pcx, pcz = table.unpack(ChunkRenderer.PreviousPosition)
		if cx == pcx and cz == pcz then
			return
		end
		
		print(cx,cz)
		local renderRadius = math.floor(ChunkRenderer.renderDistance/2)
		local inRange = {}
		local toLoad = {}
		
		for x = -renderRadius + cx, renderRadius + cx do
			for z = -renderRadius + cz, renderRadius + cz do
				local key = x.." "..z
				local chunk = ChunkRenderer.Grid[key]
				
				if distance({cx,cz},{x,z}) < renderRadius then
					if not chunk then
						ChunkRenderer.Grid[key] = Chunk.new(x,z)
						table.insert(toLoad, {x,z})
					end
					inRange[key] = true
				end
			end
		end
		
		for key, chunk in pairs(ChunkRenderer.Grid) do
			if not inRange[key] then
				coroutine.wrap(chunk.Unload)(chunk)
				ChunkRenderer.Grid[key] = nil
			end
		end
		toLoad = base93.compress(HttpService:JSONEncode(toLoad))
		remotes.GetChunk:FireServer(toLoad)
		ChunkRenderer.PreviousPosition = {cx,cz}
	end)
	
	ChunkRenderer.loadChunkEvent = remotes.GetChunk.OnClientEvent:Connect(function(grid)
		grid = HttpService:JSONDecode( base93.decompress(grid) )
		for key, data in pairs(grid) do
			local chunk = ChunkRenderer.Grid[key]
			if not chunk then continue end
			chunk.Load(chunk,data,math.clamp(math.log10(renderDistance-3)/18,0,2))
		end
	end)
	
	--ChunkRenderer.chunkUpdateEvent = remotes.Mine.OnClientEvent:Connect(function(brick, position, cx, cz)
	--	print(cx, cz)
	--	local key = cx.." "..cz
		
	--	local chunk = ChunkRenderer.Grid[key]
	--	chunk:Update(brick,position)
	--end)
end

function ChunkRenderer.UpdateChunk(chunkPos,...)
	local cx, cz = table.unpack(chunkPos)
	local chunk = ChunkRenderer.Grid[cx.." "..cz]
	if chunk then
		chunk:Update(...)
	end
end

function ChunkRenderer.UpdateRenderDistance(renderDistance)
	ChunkRenderer._renderDistance = renderDistance
end

function ChunkRenderer.CleanUp()
	ChunkRenderer.renderSteppedEvent:Disconnect()
	ChunkRenderer.loadChunkEvent:Disconnect()
	ClientStorage.PartCache:Dispose()
	ClientStorage.PartCache = nil
end

return ChunkRenderer
