local BlockEnum = require(script.Parent.BlockEnum)
local BlockConfig = {
	BlockSize = 4,
	ChunkSize = 16,

	MaterialMap = {
		[BlockEnum.Grass] = 		Enum.Material.Grass,
		[BlockEnum.Dirt] = 		Enum.Material.Ground,
		[BlockEnum.Sand] = 		Enum.Material.Sand,
		[BlockEnum.Snow] = 		Enum.Material.Snow,
		[BlockEnum.Ice] = 		Enum.Material.Ice,
		[BlockEnum.Sandstone] = 	Enum.Material.Sandstone,
		[BlockEnum.Rock] = 		Enum.Material.Rock,
		[BlockEnum.Slate] = 		Enum.Material.Slate,
		[BlockEnum.Red] = 		Enum.Material.SmoothPlastic,
		[BlockEnum.Blue] = 		Enum.Material.SmoothPlastic,
		[BlockEnum.Wood] =		Enum.Material.Wood,
		[BlockEnum.Leaves] = 	Enum.Material.LeafyGrass,
	},

	ColorMap = {
		[BlockEnum.Grass] =  	Color3.fromRGB(100,255,100),
		[BlockEnum.Dirt] = 		Color3.fromRGB(105, 64, 40),
		[BlockEnum.Sand] = 		Color3.fromRGB(248, 217, 109),
		[BlockEnum.Sandstone] = 	Color3.fromRGB(208, 138, 104),
		[BlockEnum.Snow] = 		Color3.fromRGB(255,255,255),
		[BlockEnum.Ice] =		Color3.fromRGB(85, 170, 255), 
		[BlockEnum.Rock] = 		Color3.fromRGB(100,100,100),
		[BlockEnum.Slate] = 		Color3.fromRGB(60,60,60),
		[BlockEnum.Red] = 		Color3.new(1),
		[BlockEnum.Blue] = 		Color3.new(0,.2,1),
		[BlockEnum.Wood] = 		Color3.fromRGB(143, 76, 42),
		[BlockEnum.Leaves] = 	Color3.fromRGB(0,90,0)
	},

	BiomeMap = {
		Test = 		{},
		Plains = 	{BlockEnum.Grass, BlockEnum.Dirt},
		Forest = 	{BlockEnum.Dirt, BlockEnum.Slate},
		Snow = 	 	{BlockEnum.Snow, BlockEnum.Ice},
		Arctic = 	{},
		Desert = 	{BlockEnum.Sand, BlockEnum.Sandstone},
		Red =    	{BlockEnum.Red, BlockEnum.Dirt},
		Blue =   	{BlockEnum.Blue, BlockEnum.Dirt}
	}
}

return BlockConfig
