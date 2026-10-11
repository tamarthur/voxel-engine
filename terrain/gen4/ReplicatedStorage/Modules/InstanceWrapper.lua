--[[
	Abstract class
]]
local Signal = require(game.ReplicatedStorage.Modules.Signal)
function instanceWrapper()
	local InstanceWrapper = {}
	InstanceWrapper.__index = function(self, key)
		local attribute = InstanceWrapper[key]
		if not attribute then
			local instance = rawget(self, "_instance")
			local value = instance[key]
			if type(value) == "function" then
				return function(_, ...)
					return value(instance, ...)
				end
			end
			return value
		end
		return attribute
	end
	
	InstanceWrapper.__newindex = function(self, key, value)
		local instance = rawget(self, "_instance")
		if instance and type(value) ~= "table" then
			if pcall(function() instance[key] = value end) then
				return
			end
		end
		rawset(InstanceWrapper,key,value)
	end
	
	function InstanceWrapper:SetInstance(instance)
		rawset(self, "_instance", instance)
	end
	
	function InstanceWrapper:AddEvent(event)
		rawset(self, event, Signal.new())
	end

	return InstanceWrapper
end

return instanceWrapper
