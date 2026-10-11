local Modules = game.ReplicatedStorage.Modules
local WorldBuilder = require(Modules.Utility.WorldBuilder)
local WorldConfig = require(Modules.Utility.WorldConfig)
local GenerationService = {}
math.randomseed(1)

local Noise = require(script.Noise)
local Continentalness = Noise.Continentalness
local Erosion = Noise.Erosion
local PeaksAndValleys = Noise.PeaksAndValleys

local function noise3d(x, y, z, seed)
	local ab = math.noise(x, y, seed)
	local bc = math.noise(y, z, seed)
	local ac = math.noise(x, z, seed)
	local ba = math.noise(y, x, seed)
	local cb = math.noise(z, y, seed)
	local ca = math.noise(z, x, seed)
	return math.clamp( (ab + bc + ac + ba + cb + ca)/6, -1, 1)
end

--function GenerationService:GenerateTerrainElevation()
--	return 0
--end

--function GenerationService:GenerateSurfaceNoise(squashingFactor)
--	local heightOffset = GenerationService:GenerateTerrainElevation()

--	squashingFactor = (not squashingFactor and .5) or squashingFactor

--	local height = math.clamp(wy - heightOffset, -WorldConfig.TERRAIN_RANGE + .001, WorldConfig.TERRAIN_RANGE - .001)
--	local heightBias = -height / (height^2 - WorldConfig.TERRAIN_RANGE^2 )

--	local noise = WorldGenerator.SurfaceNoise:GetNoise(wx, wy, wz)

--	return noise + heightBias * squashingFactor * WorldConfig.TERRAIN_RANGE
--end

function GenerationService:GenerateBlock(x: number, y: number, z: number)
	
	if y == 0 then
		return 2
	end
	
	if y < 0 then
		return 3
	end
	
end

function GenerationService:GenerateSurfaceChunk(cx, cz)
	
	for x = 1, WorldConfig.CHUNK_SIZE do
		for z = 1, WorldConfig.CHUNK_SIZE do
			local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, 0, z), Vector3.new(cx, 0, cz))
			local blockHeight = math.floor(math.sin(blockPosition.X) + math.cos(blockPosition.Z))
			
			local blockIndex, chunkPosition = WorldBuilder:BlockPositionToBlockIndex(Vector3.new(blockPosition.X, blockHeight, blockPosition.Z))
			
		end
	end
end

function GenerationService:GenerateChunk(key, chunk)
	local chunkPosition = Vector3.new(WorldBuilder:KeyToCoordinates(key))
	local chunkMin, chunkMax = WorldBuilder:GetChunkBlockPositionBounds(chunkPosition)
	
	debug.profilebegin("Generate chunk")
	
	for x = 1, WorldConfig.CHUNK_SIZE do
		for z = 1, WorldConfig.CHUNK_SIZE do			
			local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, 1, z), chunkPosition)
			local heightValue = 
				Noise.Surface(blockPosition.X, blockPosition.Z) +
				Continentalness(blockPosition.X, blockPosition.Z) +
				Erosion(blockPosition.X, blockPosition.Z) + 
				PeaksAndValleys(blockPosition.X, blockPosition.Z)
			local height = WorldBuilder:RoundToNearestInteger(200*heightValue/3)

			if height > chunkMax.Y then
				continue
			end
			
			local block = 2
			if height < 20 then
				block = 7
			end
			
			local y = WorldBuilder:BlockPositionToBlockIndex(Vector3.new(1, height, 1)).Y
			
			if height < chunkMin.Y then
				for y = 1, 16 do
					chunk[1][z][x] = 3
				end
				continue
			end
			
			chunk[y+1][z][x] = 1
			chunk[y][z][x] = block
			for y1 = y - 1, 1, -1 do
				chunk[y1][z][x] = 3
			end
			

			--if blockPosition.Y <= 0 then
			--	local newPos = blockPosition/20
			--	if noise3d(newPos.X, newPos.Y, newPos.Z, 1) > 0 then
			--		if blockPosition.Y < -300 then
			--			chunk[y][z][x] = 5
			--		elseif blockPosition.Y < -100 then
			--			chunk[y][z][x] = 4
			--		elseif blockPosition.Y < 0 then
			--			chunk[y][z][x] = 3
			--		elseif blockPosition.Y == 0 then
			--			chunk[y+1][z][x] = 1
			--			chunk[y][z][x] = 2
			--		end
			--	else
			--		chunk[y][z][x] = 1
			--	end
			--end

		end
	end
	
	--for y = 1, WorldConfig.CHUNK_SIZE do
	--	for x = 1, WorldConfig.CHUNK_SIZE do
	--		for z = 1, WorldConfig.CHUNK_SIZE do
	--			local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, y, z), chunkPosition)
	--			if blockPosition.Y <= 0 then
	--				local newPos = blockPosition/20
	--				if noise3d(newPos.X, newPos.Y, newPos.Z, 1) > 0 then
	--					if blockPosition.Y < -300 then
	--						chunk[y][z][x] = 5
	--					elseif blockPosition.Y < -100 then
	--						chunk[y][z][x] = 4
	--					elseif blockPosition.Y < 0 then
	--						chunk[y][z][x] = 3
	--					elseif blockPosition.Y == 0 then
	--						chunk[y+1][z][x] = 1
	--						chunk[y][z][x] = 2
	--					end
	--				else
	--					chunk[y][z][x] = 1
	--				end
	--			end
				
	--		end
	--	end
	--end	
	
	--if chunkPosition.Y == 0 then
	--	for x = 1, 16 do
	--		for z = 1, 16 do
				
	--			local blockPosition = WorldBuilder:BlockIndexToBlockPosition(Vector3.new(x, 8, z), chunkPosition)
	--			--chunk[z][9][x] = 1
	--			chunk[9][z][x] = 1
	--			chunk[8][z][x] = 2
	--			--chunk[math.random(1,7)][x][z] = math.random(2,5)
	--			--chunk[math.random(1,7)][x][z] = math.random(2,5)
	--			--chunk[math.random(1,7)][x][z] = math.random(2,5)
	--			--chunk[math.random(1,7)][x][z] = math.random(2,5)
	--			--chunk[math.random(1,7)][x][z] = math.random(2,5)

	--		end
	--	end

	--end
	debug.profileend()
	return chunk
end

return GenerationService
