function largestRectangle(grid)
	local maxima = {}
	local currentRow = {}

	for row, colData in pairs(grid) do
		--print(row,"r")
		for col, filled in pairs(colData) do--setting up current row stack
			--print(col,"c")
			local currentCell = grid[row][col]--height
			local previousCell = grid[row-1] and grid[row-1][col]

			if not currentRow[currentCell] then -- set up y level
				currentRow[currentCell] = {}
			end
			if not maxima[currentCell] then
				maxima[currentCell] = {
					["X"] = 0,
					["Z"] = 0,
					["Length"] = 0,
					["Height"] = 0,
					["Area"] = 0,
				}
			end

			local isSame = previousCell == currentCell
			if previousCell and isSame then
				currentRow[currentCell][col] += 1
			else
				currentRow[currentCell][col] = 1
			end

		end
		print(currentRow)

		local max = {
			["Area"] = 0,
			["Length"] = 0,
			["Height"] = 0,
			["X"] = 0,
			["Z"] = 0,
		}
		--print(currentRow)
		for level, data in pairs(currentRow) do
			local largest = maxima[level]
			print(data)
			for col, _ in pairs(data) do
				print(_,data[col])
				local height = data[col].Value
				local left = 0
				local right = 0

				while data[col-left-1] do
					if data[col-left-1].Value >= height then
						left += 1
					else
						break
					end
				end
				while data[col+right+1] do
					if data[col+right+1].Value >= height then
						right += 1
					else
						break
					end
				end
				data[col].LeftOffset = left
				data[col].RightOffset = right
				local length = math.abs(right-left)+1
				local area = length*height
				if area > max.Area then
					max.Area = area
					max.Length = length
					max.Height = height
					max.X = col
					max.Z = row
				end
			end

			if max.Area > largest.Area then
				largest = max
				largest["Z"] = max.Z - max.Height/2
				largest["X"] = max.X - max.Length/2
			end 
		end
	end
	return maxima
end

local x = {
	{.2,.2,1},
	{.2,4,1},
	{.2,.2,.2},
}

print(largestRectangle(x))

local q = {
	[3]=1,
	[4]=2,
	[5]=3
}
for i,v in pairs(q) do
	print(i,v)
end
