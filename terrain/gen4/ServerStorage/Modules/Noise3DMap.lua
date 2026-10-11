local Noise3DMap = {}

function perlin3D(x: number, y: number, z: number, seed: number): number
	local AB = math.noise(x,y,seed)
	local BC = math.noise(y,z,seed)
	local AC = math.noise(x,z,seed)

	local BC = math.noise(y,x,seed)
	local CB = math.noise(z,y,seed)
	local CA = math.noise(z,x,seed)

	local ABC = AB + BC + AC + BC + CB + CA
	return ABC/6
end

local Noise3DMap = {}
Noise3DMap.__index = Noise3DMap

function Noise3DMap.new(seed, scale, octaves, lacunarity, persistance)
	--[[
		Lacunarity controls increase in frequency of octaves (small features)
		Persistance controls decrease in amplitude of octaves (how much small features influence overall shape)
	]]
	local self = setmetatable({},Noise3DMap)
	self.Seed = seed
	self.Scale = scale
	self.Octaves = octaves
	self.Lacunarity = lacunarity
	self.Persistance = persistance
	return self
end

function Noise3DMap:GetNoise(x,y,z)
	local noiseHeight = 0
	local amplitude = 1
	local frequency = 1
	for i = 1, self.Octaves do	
		local sampleX = x / self.Scale * frequency
		local sampleY = y / self.Scale * frequency
		noiseHeight += amplitude * math.noise(sampleX,sampleY,self.Seed)

		amplitude *= self.Persistance
		frequency *= self.Lacunarity
	end
	return noiseHeight
end

return Noise3DMap
