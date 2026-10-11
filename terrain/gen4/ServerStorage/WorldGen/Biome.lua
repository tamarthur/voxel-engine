local Biomes = {}

for _, biome in ipairs(script:GetChildren()) do
	Biomes[biome.Name] = require(biome)
end

return Biomes
