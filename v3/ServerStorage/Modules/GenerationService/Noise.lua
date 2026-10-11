local Noise = {}

local SCALE = 100
local FractalNoise = require(game.ServerStorage.Modules.Util.FractalNoise)
local fractalNoise = {
	GetNoise = function(_, x, z)
		return math.noise(x/SCALE, z/SCALE, 10)
	end,	
}
fractalNoise = FractalNoise.new(1,400,3,3,.25)


function _LinearPiecewise(spline: {{number}}, x: number)
	for i = 2, #spline do
		local x1, y1 = table.unpack(spline[i - 1])
		local x2, y2 = table.unpack(spline[i])
		
		if x1 <= x and x <= x2 then
			return (y2 - y1)/(x2 - x1) * (x - x1) + y1
		end
	end
end

function Noise.Surface(x: number, z: number)
	return fractalNoise:GetNoise(x + 100, z + 100)/4
end

function Noise.Continentalness(x: number, z: number)
	local spline = {
		{-1, 1},
		{-.9, .05},
		{-.35, .05},
		{-.3, .4},
		{0, .4},
		{.05, .925},
		{.18, .94},
		{.3, .95},
		{.5, .985},
		{.7, .99},
		{1, 1},
	}

	return _LinearPiecewise(spline, fractalNoise:GetNoise(x, z))
end

function Noise.Erosion(x: number, z: number)
	local spline = {
		{-1, 1},
		{-.9, .8},
		{-.5, .6},
		{-.4, .675},
		{-.15, .125},
		{.2, .11},
		{.4, .11},
		{.42, .375},
		{.6, .375},
		{.62, .11},
		{.85, .05},
		{1, .05},
	}
	return _LinearPiecewise(spline, fractalNoise:GetNoise(x, z))
end

function Noise.PeaksAndValleys(x: number, z: number)
	local spline = {
		{-1, 0},
		{-.8, .15},
		{-.3, .3},
		{.1, .33},
		{.6, .9},
		{1, 1},
	}
	return _LinearPiecewise(spline, fractalNoise:GetNoise(x, z))
end

return Noise
