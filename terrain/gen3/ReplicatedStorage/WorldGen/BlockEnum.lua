local map = {
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
}

for i,v in pairs(map) do
	map[v] = i
end

return map
