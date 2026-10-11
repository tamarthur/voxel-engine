local WorldConfig = require(script.Parent.WorldConfig)
local WorldGrid = {}

return setmetatable(WorldGrid, {
	__index = function(self, key)
		local value = rawget(self, key)
		if not value then
			local data = {}
			for x = 1, WorldConfig.CHUNK_SIZE do
				data[x] = {}
				for z = 1, WorldConfig.CHUNK_SIZE do
					data[x][z] = {}
				end
			end
			self[key] = {Data = data, Hull = {}, Edge = {}}
			return rawget(self, key)
		end
		return value
	end
})
