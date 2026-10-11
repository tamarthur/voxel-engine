local Item = {}
Item.__index = Item

function Item.new(player)
	local self = {
		Owner = player,
	}
	return setmetatable(self, Item)
end

function Item:Equip()
	
end

function Item:Unequip()
	
end

function Item:Destroy()
	
end

return Item
