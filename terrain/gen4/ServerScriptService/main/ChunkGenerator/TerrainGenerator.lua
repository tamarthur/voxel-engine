local TerrainGenerator = {}
TerrainGenerator.__index = TerrainGenerator

local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local sharedModules = ReplicatedStorage.Modules
local modules = ServerStorage.Modules

local BlockConfig = require(sharedModules.BlockConfig)
local FractalNoise = require(modules.FractalNoise)

function gridToMap(noise)
	return math.floor(noise/BlockConfig.BlockSize)*BlockConfig.BlockSize
end

function TerrainGenerator.new()
	local SEED = 69696
	local self = setmetatable({},TerrainGenerator)
	self.SurfaceNoise = FractalNoise.new(SEED,100,3,3,.35)
	self.TemperatureNoise = FractalNoise.new(SEED,1000,2,3,.5)
	self.VegetationChance = Random.new(SEED)
	return self
end

function TerrainGenerator:Generate(x,y,z)
	local surface = gridToMap(50*self.SurfaceNoise:GetNoise(x,z))-2
	local biomeNoise = self.TemperatureNoise:GetNoise(x,z)
	local biome
	if biomeNoise < -1/3 then
		biome = "Snow"
	elseif biomeNoise >= -1/3 and biomeNoise <= 1/3 then
		biome = "Plains"
	else					
		biome = "Desert"
	end
	local blockID = BlockConfig.BiomeMap[biome][1]
	return surface, blockID
end

return TerrainGenerator
