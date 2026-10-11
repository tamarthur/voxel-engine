local worldGen = game.ReplicatedStorage.WorldGen
local BlockEnum = require(worldGen.BlockEnum)
local Config = {
	BlockSize = 4,
	ChunkSize = 16,
	
	MaterialMap = {
		Grass = Enum.Material.Grass,
		Dirt = Enum.Material.Ground,
		Sand = Enum.Material.Sand,
		Snow = Enum.Material.Snow,
		Ice = Enum.Material.Ice,
		Sandstone = Enum.Material.Sandstone,
		Rock = Enum.Material.Rock,
		Slate = Enum.Material.Slate,
		Red = Enum.Material.SmoothPlastic,
		Blue = Enum.Material.SmoothPlastic,
	},
	
	ColorMap = {
		Grass = Color3.fromRGB(100,255,100),
		Dirt = Color3.fromRGB(105, 64, 40),
		Sand = Color3.fromRGB(248, 217, 109),
		Sandstone = Color3.fromRGB(208, 138, 104),
		Snow = Color3.fromRGB(255,255,255),
		Ice = Color3.fromRGB(85, 170, 255), 
		Rock = Color3.fromRGB(100,100,100),
		Slate = Color3.fromRGB(60,60,60),
		Red = Color3.new(1),
		Blue = Color3.new(0,.2,1)
	},
	
	BiomeMap = {
		Plains = {"Grass","Dirt"},
		Forest = {},
		Snow = {"Snow","Ice"},
		Arctic = {},
		Desert = {"Sand","Sandstone"},
		Red = {"Red","Dirt"},
		Blue = {"Blue","Dirt"}
	}
}

return Config
