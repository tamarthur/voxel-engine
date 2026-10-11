local plr = game.Players.LocalPlayer
local char = plr.Character

local BLOCK_SIZE = 4
local SEED = 1000
local COLOR = Color3.fromRGB(75, 151, 75)

local green = {
	Color3.fromRGB(40, 127, 71),
	Color3.fromRGB(52, 142, 64),
	Color3.fromRGB(75, 151, 75),
	Color3.fromRGB(91, 154, 76),
}

local yellow = {
	Color3.fromRGB(245, 205, 48),
	Color3.fromRGB(75, 151, 75),
	Color3.fromRGB(91, 154, 76),
}

local function equation(x:number,z:number):number
	
	return math.noise(x/BLOCK_SIZE,z/BLOCK_SIZE)
end



for x = -10,10 do
	for z = -10,10 do
		local y = equation(x,z)
		print(y)
		local fixedY = BLOCK_SIZE*math.floor((y*10)/BLOCK_SIZE)
		local part = Instance.new("Part",workspace)
		part.Size = Vector3.new(BLOCK_SIZE,BLOCK_SIZE,BLOCK_SIZE)
		part.Anchored = true
		part.Position = Vector3.new(x*BLOCK_SIZE,y,z*BLOCK_SIZE)
		
		
		local h,s,v = COLOR:ToHSV()
		local percent = math.abs(y)*1.3
		print(percent)
		part.Color = Color3.fromHSV(h,s*percent,v)
	end
end
