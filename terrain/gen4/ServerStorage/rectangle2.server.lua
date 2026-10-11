function maximalRectangle(data)
	if not next(data) then return end

	local nCol = 16
	local nRow = 16

	local left, right, height = table.create(nRow,0),table.create(nRow,nRow),table.create(nRow,0)

	local maxL, maxR, maxH, maxA, cur_row = 0, 0, 0, 0, 0
	for i = 1, nCol do
		local cur_left, cur_right = 1, nRow
		local test = 0
		for j = 1, nRow do
			if data[i.." "..j]  then
				height[j] += 1
				test += 1
			else
				height[j] = 0
			end
		end
		--if test == 1 then
		--	print(height)
		--end
		for j = 1, nRow do
			if data[i.." "..j] then
				left[j] = math.max(left[j],cur_left)
			else
				left[j] = 0
				cur_left = j + 1
			end
		end
		for j = nRow-1, 1, -1 do
			if data[i.." "..j] then
				right[j] = math.min(right[j],cur_right)
			else
				right[j] = nRow
				cur_right = j
			end
		end
		for j = 1, nRow do
			local area = math.clamp(right[j]-left[j],1,100)*height[j]
			if area > maxA then
				maxA, maxL, maxR, maxH, cur_row = area, left[j], right[j], height[j], i
			end
		end
	end
	
	--if cur_row == 0 then
	--	return
	--end
	print(left,right,height)
	return {maxL, maxR, maxH, cur_row}
end

local data = {
	{0,0,0,0,0,0,0},
	{1,0,0,0,0,1,0},
	{1,1,1,0,0,1,0},
	{1,1,1,1,0,0,0},
	{0,0,0,0,0,1,0},
	{0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0},
}
local row = #data[1]
local col = #data

function gridToMap(noise)
	return math.floor(noise/4)*4
end

local chunk = {}
local testChunk = {}
for x = 1, 16 do
	for z = 1, 16 do
		local blockX = (0 * 16) + x
		local blockZ = (0 * 16) + z

		local y = gridToMap(24*math.sin(blockX/16) + 24*math.cos(blockZ/16))
		if not chunk[y] then
			chunk[y] = {}
		end
		chunk[y][x.." "..z] = 2
	end
end

for y, grid in pairs(chunk) do
	local rectData = maximalRectangle(grid,row,col)
	local test = 0
	while rectData do
		if test == 12 then break end
		local rectLeft, rectRight, rectHeight, rectBottom = table.unpack(rectData) 
		local rectTop = rectBottom - rectHeight + 1

		print("LB: "..rectLeft,"RB: "..rectRight,"TOP: "..rectTop,"BOTTOM: "..rectBottom,"HEIGHT "..rectHeight)
		print(grid)

		for z = rectLeft, rectRight do
			for x = rectTop, rectBottom do
				grid[x.." "..z] = nil
			end
		end
		test += 1
		print("after removing")
		print(grid)

		rectData = maximalRectangle(grid)
	end
	print(test)
end
