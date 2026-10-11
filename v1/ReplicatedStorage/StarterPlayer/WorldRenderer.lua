local HttpService = game:GetService("HttpService")

local Modules = game.ReplicatedStorage.Modules

local WorldUtil = require(Modules.Terrain.WorldUtil)
local WorldConfig = require(Modules.Terrain.WorldConfig)
local BlockEnum = require(Modules.Terrain.BlockEnum)
local Chunk = require(Modules.Terrain.Chunk)

local PartCache = require(Modules.Util.PartCache)

local base93 = require(Modules.Util.base93)
local Requests = game.ReplicatedStorage.Requests

local WorldRenderer = {}

function WorldRenderer.Init()
	--_G.Player.CharacterAdded:Wait()
	print("WorldRenderer initialized")
	
	_G.Player.CameraMaxZoomDistance = 1e9
	
	local humanoidRootPart = _G.Character.HumanoidRootPart
	local renderDistance = 8
	_G.ClientStorage.PartCache = PartCache.new(game.ReplicatedStorage.Assets.Block, renderDistance^3)
	WorldRenderer.Grid = {}
	
	local previousPosition = {0,0,0}
	game:GetService("RunService").Heartbeat:Connect(function()
		local cx, cy, cz = WorldUtil.worldToChunkPosition(humanoidRootPart.Position)
		local pcx, pcy, pcz = table.unpack(previousPosition)
		if cx == pcx and cy == pcy and cz == pcz then
			return
		end

		print("Chunk Position: ",cx,cy,cz)
		local renderRadius = math.floor(renderDistance/2)
		local inRange = {}
		local toLoad = {}

		for x = -renderRadius + cx, renderRadius + cx do
			for z = -renderRadius + cz, renderRadius + cz do
				for y = -renderRadius + cy, renderRadius + cy do
					
					
					
					local key = WorldUtil.stringify(x, y, z)
					local chunk = WorldRenderer.Grid[key]
					
					if Vector3.new(x - cx, y - cy, z - cz).Magnitude < renderRadius then
						--print(cx, cy, cz)
						if not chunk then
							WorldRenderer.Grid[key] = Chunk.new(x, y, z)
							table.insert(toLoad, {x, y, z})
						end
						inRange[key] = true
					end
					
				end
			end
		end

		for key, chunk in pairs(WorldRenderer.Grid) do
			if not inRange[key] then
				coroutine.wrap(chunk.Unload)(chunk)
				WorldRenderer.Grid[key] = nil
			end
		end
		toLoad = base93.compress(HttpService:JSONEncode(toLoad))
		Requests.GetChunks:FireServer(toLoad)
		previousPosition = {cx, cy, cz}
	end)
	
	Requests.GetChunks.OnClientEvent:Connect(function(chunks)
		for key, data in pairs(chunks) do
			local chunk = WorldRenderer.Grid[key]
			
			if not chunk then continue end
			
			if chunk.Loaded then continue end
			
			local chunkData = data-- HttpService:JSONDecode( base93.decompress(data) )
			chunk:Load(chunkData)
			
			--local cx, cy, cz = table.unpack(key:split(" "))
			
			--for position, ID in pairs(chunk) do
			--	local x, y, z = table.unpack(position:split(" "))
			--	local part = Instance.new("Part", workspace)
			--	part.Size = Vector3.one * WorldConfig.BLOCK_SIZE
			--	part.Anchored = true
			--	part.Position = Vector3.new(WorldUtil.getWorldPosition(cx, cy, cz, x, y, z))
			--	part.Color = BlockEnum.fromID[ID or 1].Color or Color3.new()
			--end
			
			--print(chunk)
			--local chunk = WorldRenderer.Grid[key]
			--if not chunk then continue end
			--chunk.Load(chunk,data,math.clamp(math.log10(renderDistance-3)/18,0,2))
		end
	end)
	
end

return WorldRenderer
