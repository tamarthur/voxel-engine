local FractalNoise = {}
FractalNoise.__index = FractalNoise

	local function noise3d(x, y, z, seed)
		local ab = math.noise(x, y, seed)
		local bc = math.noise(y, z, seed)
		local ac = math.noise(x, z, seed)
		local ba = math.noise(y, x, seed)
		local cb = math.noise(z, y, seed)
		local ca = math.noise(z, x, seed)
		return math.clamp( (ab + bc + ac + ba + cb + ca)/6, -1, 1)
	end

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

function FractalNoise:GetNoise(x, y, z)
	local noiseHeight = 0
	local amplitude = 1
	local frequency = 1
	for i = 1, self.Octaves do	
		local sampleX = x / self.Scale * frequency
		local sampleY = y / self.Scale * frequency
		local sampleZ = z / self.Scale * frequency
		noiseHeight += amplitude * math.clamp(noise3d(sampleX, sampleY, sampleZ, self.Seed),-1,1)
		
		amplitude *= self.Persistance
		frequency *= self.Lacunarity
	end
	return noiseHeight
end

return FractalNoise
