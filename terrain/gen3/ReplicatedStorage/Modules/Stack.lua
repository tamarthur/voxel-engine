local Stack = {}
Stack.__index = Stack

function Stack.new()
	return setmetatable({
		["_list"] = {}	
	},Stack)
end

function Stack:Pop()
	self._list[#self._list] = nil
end

function Stack:Append(item)
	table.insert(self._list,item)
end

return Stack
