function largestRectangle(grid)
	local largest = {
		["X"] = 0,
		["Z"] = 0,
		["Length"] = 0,
		["Height"] = 0,
		["Area"] = 0,
	}

	local currentRow = {}

	for row, colData in pairs(grid) do
		--print(row,"r")
		local newRow = {}
		for col, filled in pairs(colData) do--setting up current row stack
			--print(col,"c")
			local currentCell = grid[row][col]
			local previousCell = grid[row-1] and grid[row-1][col]

			newRow[col] = {}

			--print(currentCell,previousCell, row, col)

			if currentCell and previousCell and currentRow[col] then -- 1 is true and 0 is nil
				newRow[col].Value = currentRow[col].Value + 1
			else
				newRow[col].Value = currentCell and 1 or nil
			end
			--print(currentRow)
		end
		currentRow = newRow
		print(currentRow)

		local max = {
			["Area"] = 0,
			["Length"] = 0,
			["Height"] = 0,
			["X"] = 0,
			["Z"] = 0,
		}
		--print(currentRow)
		for col, _ in pairs(currentRow) do
			local height = currentRow[col].Value
			local left = 0
			local right = 0

			while currentRow[col-left-1] do
				if currentRow[col-left-1].Value >= height then
					left += 1
				else
					break
				end
			end
			while currentRow[col+right+1] do
				if currentRow[col+right+1].Value >= height then
					right += 1
				else
					break
				end
			end
			currentRow[col].LeftOffset = left
			currentRow[col].RightOffset = right
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
			largest["Z"] = max.Z + max.Height/2
			largest["X"] = max.X + max.Length/2
		end
	end
	return largest
end

local x = {
	--[1] = {},
	[2] = {[1] = true,[2] = true,[3] = true},
	[3] = {[1] = true,[2] = true,[3] = true}
}
local rectangle = largestRectangle(x)
print(rectangle)
--for row = rectangle.Z-rectangle.Height/2+1, rectangle.Z+rectangle.Height/2+1 do
--	--if not level[row] then continue end
--	for col = rectangle.X-rectangle.Length/2+1, rectangle.X+rectangle.Length/2+1 do
--		--print(level[row],row,col)
--		print(row,col)
--	end
--	--level[row] = nil
--end
