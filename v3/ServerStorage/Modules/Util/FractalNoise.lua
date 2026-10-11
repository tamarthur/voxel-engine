local FractalNoise = {}
FractalNoise.__index = FractalNoise

function FractalNoise.new(seed, scale, octaves, lacunarity, persistance)
	--[[
		Lacunarity controls increase in frequency of octaves (small features)
		Persistance controls decrease in amplitude of octaves (how much small features influence overall shape)
	]]
	local self = setmetatable({},FractalNoise)
	self.Seed = seed
	self.Scale = scale
	self.Octaves = octaves
	self.Lacunarity = lacunarity
	self.Persistance = persistance
	return self
end

function FractalNoise:GetNoise(x, y)
	local noiseHeight = 0
	local amplitude = 1
	local frequency = 1
	for i = 1, self.Octaves do	
		local sampleX = x / self.Scale * frequency
		local sampleY = y / self.Scale * frequency
		noiseHeight += amplitude * math.clamp(math.noise(sampleX,sampleY,self.Seed),-1,1)

		amplitude *= self.Persistance
		frequency *= self.Lacunarity
	end
	return noiseHeight
end

return FractalNoise
