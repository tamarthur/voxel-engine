local BiomeGenerator = {}
BiomeGenerator.__index = BiomeGenerator

local ServerStorage = game.ServerStorage
local ReplicatedStorage = game.ReplicatedStorage

local sharedModules = ReplicatedStorage.Modules
local modules = ServerStorage.Modules

local WorldGenConfig = require(modules.WorldGenConfig)
local FractalNoise = require(modules.FractalNoise)

local biomeMap = {}

function distance(p1,p2)
	return math.sqrt( math.pow(p2[1]-p1[1], 2) + math.pow(p2[2]-p1[2], 2) )
end

function getNearestBiome()
	
end

function BiomeGenerator.new()
	local SEED = 69696
	local self = setmetatable({},BiomeGenerator)
	self.TemperatureNoise = FractalNoise.new(SEED,1000,1, 1, 0)
	self.HumidityNoise = FractalNoise.new(SEED,500,1,1, 0)
	return self
end

function BiomeGenerator:Generate(x,y,z)
	local tempNoise = self.TemperatureNoise:GetNoise(x,z)
	local humidNoise = self.HumidityNoise:GetNoise(x,z)
	
	local closestTemp = -2
	local closestHumid = -2
	for i,v in pairs(WorldGenConfig.Biomes) do
		
	end
end

return BiomeGenerator
