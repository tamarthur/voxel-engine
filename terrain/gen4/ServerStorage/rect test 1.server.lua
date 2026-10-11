function maximalRectangle(data)
	if not next(data) then return end

	local nCol = 5
	local nRow = nCol

	local height = table.create(nRow,0)

	local maxA, maxL, maxR, maxH, cur_row = 0, 0, 0, 0, 0
	for i = 1, nCol do
		local left, right = table.create(nRow,0), table.create(nRow,0)
		for j = 1, nRow do
			if data[i.." "..j] then
				height[j] += 1
			else
				height[j] = 0
			end
		end

		for j = 1, nRow do
			local cur_left, cur_right = j - 1, j + 1
			while height[cur_left] do
				if height[j] <= height[cur_left] then
					cur_left -= 1
				else
					break
				end
			end
			while data[cur_right] do
				if height[j] <= height[cur_right] then
					cur_right += 1
				else
					break
				end
			end

			local area = (cur_right-cur_left) * height[j]
			if area >= maxA then
				maxA, maxL, maxR, maxH, cur_row = area, cur_left + 1, cur_right - 1, height[j], i
			end
		end
	end
	return {maxL, maxR, maxH, cur_row}
end
--local data = {
--	[1] = {[2] = 1, [3] = 1, [4] = 1},
--	[2] = {[2] = 1},
--}

local data = {
	["1 1"] = true, ["1 2"] = nil, ["1 3"] = nil, ["1 4"] = true, ["1 5"] = nil,
	["2 1"] = true, ["2 2"] = nil, ["2 3"] = true, ["2 4"] = true, ["2 5"] = true,
	["3 1"] = true, ["3 2"] = nil, ["3 3"] = true, ["3 4"] = true, ["3 5"] = true,
	["4 1"] = true, ["4 2"] = true, ["4 3"] = true, ["4 4"] = true, ["4 5"] = true,
	["5 1"] = true, ["5 2"] = nil, ["5 3"] = nil, ["5 4"] = true, ["5 5"] = true,
}

local chunk = {data}

function gridToMap(noise)
	return math.floor(noise/4)*4
end

local testChunk = {}
--for x = 1, 16 do
--	for z = 1, 16 do
--		local blockX = (0 * 16) + x
--		local blockZ = (0 * 16) + z

--		local y = gridToMap(24*math.sin(blockX/16) + 24*math.cos(blockZ/16))
--		if not chunk[y] then
--			chunk[y] = {}
--		end
--		chunk[y][x.." "..z] = 2
--	end
--end

for y, data in pairs(chunk) do
	local rectData = maximalRectangle(data)
	local test = 1
	while rectData do
		if test == 50 then break end
		local rectLeft, rectRight, rectHeight, rectBottom = table.unpack(rectData) 
		local rectTop = rectBottom - rectHeight + 1

		print("LB: "..rectLeft,",RB: "..rectRight,",TOP: "..rectTop,",BOTTOM: "..rectBottom,",HEIGHT "..rectHeight)
		
		print(data)
		for x = rectTop, rectBottom do
			for z = rectLeft, rectRight do
				--print(x,z,data)
				data[x.." "..z] = nil
			end
		end
		test += 1
		print("after clearing")
		print(data)

		rectData = maximalRectangle(data)
	end
	print("TEST: "..test)
	print(data)
end
