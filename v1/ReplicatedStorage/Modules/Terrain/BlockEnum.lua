local BlockEnum = {}

BlockEnum.fromID = {
	{Name = "Invalid", Color = Color3.new()},
	{Name = "Grass", Color = Color3.fromRGB(75, 151, 75)},
	{Name = "Dirt", Color = Color3.fromRGB(106, 57, 9)},
	{Name = "Stone", Color = Color3.fromRGB(99, 95, 98)},
	{Name = "Bedrock", Color = Color3.fromRGB(27, 42, 53)},
}

BlockEnum.fromName = {}
for i, v in pairs(BlockEnum.fromID) do
	v.ID = i
	BlockEnum.fromName[v.Name] = v
end

return BlockEnum
