--!strict
--[[
	General purpose optimized tensor 
]]
local Tensor = {}
Tensor.__index = Tensor

function Tensor.new(dim: number): any
	if dim == 1 then return {} end
	return setmetatable({}, {
		__index = function(self, key)
			if type(key) == "number" then
				local value = rawget(self, key)
				if not value then
					self[key] = Tensor.new(dim - 1)
					return rawget(self, key)
				end
				return value
			end
			return rawget(Tensor, key)
		end,
	})
end

function Tensor:IsEmpty(): boolean
	return next(self) == nil
end

function Tensor:Get(...: number): any
	local args = {...}
	local v = rawget(self, args[1])
	table.remove(args, 1)
	if not v then return nil end
	if #args == 0 then return v end
	if not getmetatable(v) then return v[args[1]] end
	return v:Get(table.unpack(args))
end

function Tensor:Set(...: any)
	local args = {...}
	local cur = self
	for i = 1, #args - 2 do
		cur = cur[args[i]]
	end
	cur[args[#args - 1]] = args[#args]
end

function Tensor:Iterate(callback: (any), ...: number?)
	for i, v in self do
		local args = {...}
		table.insert(args, i)
		if getmetatable(v) then
			v:Iterate(callback, table.unpack(args))
			continue
		end
		for j, k in v do
			local args = table.clone(args)
			table.insert(args, j)
			table.insert(args, k)
			callback(table.unpack(args))
		end
	end
end

return Tensor
