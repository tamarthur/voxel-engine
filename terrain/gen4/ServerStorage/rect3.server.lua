function maximalRectangle(data)
	if #data == 0 then return end

	local nCol = #data
	local nRow = #data[1]

	local left, right, height = table.create(nRow,0),table.create(nRow,nRow),table.create(nRow,0)

	local maxL, maxR, maxH, maxA, cur_row = 0, 0, 0, 0, 0
	for i = 1, nCol do
		local cur_left, cur_right = 1, nRow
		for j = 1, nRow do
			if data[i][j] == 1 then
				height[j] += 1
			else
				height[j] = 0
			end
		end
		for j = 1, nRow+1 do
			if data[i][j] == 1 then
				height[j] += 1
			else
				height[j] = 0
			end
		end
		
		--[[
			for i in xrange(n + 1):
            while height[i] < height[stack[-1]]:
				h = height[stack.pop()]
				w = i - 1 - stack[-1]
				ans = max(ans, h * w)
			stack.append(i)
		]]
	end
	if cur_row == 0 then
		return
	end

	return {maxL, maxR, maxH, cur_row}
end
