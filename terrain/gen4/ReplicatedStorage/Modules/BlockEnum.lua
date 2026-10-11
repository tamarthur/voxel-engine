local map = {
	"",
	"Grass",
	"Dirt",
	"Sand",
	"Sandstone",
	"Snow",
	"Ice",
	"Rock",
	"Slate",
	"Red",
	"Blue",
	"Wood",
	"Leaves",
}

local BlockValues = {
	Grass = 		{Color3.fromRGB(100,255,100), Enum.Material.Grass},
	Dirt = 		{Color3.fromRGB(105, 64, 40), Enum.Material.Ground},
	Sand = 		{Color3.fromRGB(248, 217, 109), Enum.Material.Sand},
	Snow = 		{Color3.fromRGB(208, 138, 104), Enum.Material.Snow},
	Ice = 		{Color3.fromRGB(255,255,255), Enum.Material.Ice},
	Sandstone = 	{Color3.fromRGB(85, 170, 255), Enum.Material.Sandstone},
	Rock = 		{Color3.fromRGB(100,100,100), Enum.Material.Rock},
	Slate = 		{Color3.fromRGB(60,60,60), Enum.Material.Slate},
	Red = 		{Color3.new(1), Enum.Material.SmoothPlastic},
	Blue = 		{Color3.new(0,.2,1), Enum.Material.SmoothPlastic},
	Wood =		{Color3.fromRGB(143, 76, 42), Enum.Material.Wood}
}

for i,v in pairs(map) do
	map[v] = i
end

return map
