function maximalRectangle(data)
	if #data == 0 then return end

	local nCol = 3
	local nRow = 3

	local left, right, height = table.create(nRow,0),table.create(nRow,nRow),table.create(nRow,0)

	local maxL, maxR, maxH, maxA, cur_row = 0, 0, 0, 0, 0
	for i = 1, nCol do
		local cur_left, cur_right = 1, nRow
		for j = 1, nRow do
			if data[i.." "..j] then
				height[j] += 1
			else
				height[j] = 0
			end
		end
		for j = 1, nRow do
			if data[i.." "..j] then
				left[j] = math.max(left[j],cur_left)
			else
				left[j] = 0
				cur_left = j + 1
			end
		end
		for j = nRow-1, 1, -1 do
			if data[i.." "..j] == 1 then
				right[j] = math.min(right[j],cur_right)
			else
				right[j] = nRow
				cur_right = j
			end
		end
		for j = 1, nRow do
			local area = (right[j]-left[j])*height[j]
			if area > maxA then
				maxA, maxL, maxR, maxH, cur_row = area, left[j], right[j]-1, height[j], i
			end
		end
	end
	if cur_row == 0 then
		return
	end

	return {maxL, maxR, maxH, cur_row}
end

local data = {
	{[2] = 1},
	{[2] = 1},
	{[2] = 1},
}
local rectData = maximalRectangle(data)
local test = 1
while rectData do
	if test == 12 then break end
	local rectLeft, rectRight, rectHeight, rectBottom = table.unpack(rectData) 
	local rectTop = rectBottom - rectHeight + 1
	
	print("LB: "..rectLeft,"RB: "..rectRight,"TOP: "..rectTop,"BOTTOM: "..rectBottom,"HEIGHT "..rectHeight)

	for z = rectLeft, rectRight do
		for x = rectTop, rectBottom do
			data[x.." "..z] = nil
		end
	end
	test += 1
	print(data)
	
	rectData = maximalRectangle(data)
end
print(test)
print(data)

for i = 1, 1 do
	print(i)
end
