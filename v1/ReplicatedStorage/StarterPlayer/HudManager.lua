local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemFrame = require(ReplicatedStorage.Modules.Objects.ItemFrame)
local HudManager = {}

function HudManager.ItemFrameActivate(slotNumber)
	print(slotNumber)
end

function HudManager.SetCenteredPosition(itemFrame, number, total)
	local frameSize = itemFrame.Frame.Size
	local hotbarSize = HudManager.HotbarFrame.Size
	
	local centerOffset = hotbarSize.X.Offset/2 - (total*(frameSize.X.Offset + HudManager.FramePadding) + HudManager.FramePadding)/2
	
	itemFrame.CenteredPosition = itemFrame.OrderedPosition + UDim2.new(0,centerOffset,0,0)
	itemFrame.Frame.Position = itemFrame.CenteredPosition
end

function HudManager.SetHotbarFramesCentered()
	--local total = 0
	--local frames = {}
	for ID = 1, 10 do
		local itemFrame = HudManager["ItemFrame"..ID]
		if not itemFrame.Item then
			itemFrame:Hide()
		else
			itemFrame:Show()
			--total += 1
			--table.insert(frames, ID)
		end
	end
	--for n, ID in ipairs(frames) do
	--	local itemFrame = HudManager["ItemFrame"..ID]
	--	--HudManager.SetCenteredPosition(itemFrame, n, total)
	--	itemFrame:Show()
	--end
end

function HudManager.ToggleInventory(toggle)
	if HudManager.InventoryFrame.Visible then
		for ID = 1, 60 do
			local itemFrame = HudManager["ItemFrame"..ID]
			itemFrame:DisableDragging()
		end
		HudManager.SetHotbarFramesCentered()
	else
		for ID = 1, HudManager.ITEM_SLOTS do
			local itemFrame = HudManager["ItemFrame"..ID]
			itemFrame:Show()
			itemFrame:EnableDragging()
		end
	end
	HudManager.InventoryFrame.Visible = not HudManager.InventoryFrame.Visible
end

function HudManager.Init()
	_G.Hud = _G.Player:WaitForChild("PlayerGui"):WaitForChild("Hud")
	
	HudManager.InventoryFrame = _G.Hud.Inventory
	HudManager.HotbarFrame = _G.Hud.Hotbar
	
	HudManager.ITEM_SLOTS = 60
	HudManager.FramePadding = 5
	
	HudManager.InventoryFrame.Visible = false

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	--if true then return end
	
	local function hotbarFrameSetup(ID, key, bind)
		local item = (ID < 9 and workspace.Interactive:GetChildren()[math.random(1,5)].Name or nil)
		local itemFrame = ItemFrame.new(HudManager.HotbarFrame, ID, item, key)
		
		HudManager["ItemFrame"..ID] = itemFrame
		HudManager[bind] = function()
			itemFrame:Activate()
			--HudManager.ItemFrameActivate(key)
		end
	end
	
	local hotbarKeys = {}
	for keycode, bind in pairs(_G.InputController.GetKeybinds("HudManager")) do
		if bind:find("Hotbar") then
			local num = bind:sub(#"Hotbar"+1, #"Hotbar"+1)
			hotbarKeys[tonumber(num)] = keycode
		end
	end
	
	for i = 1, 9 do
		hotbarFrameSetup(i, hotbarKeys[i], "Hotbar"..i)
	end
	hotbarFrameSetup(10, hotbarKeys[0], "Hotbar0")
	HudManager.SetHotbarFramesCentered()
	
	for ID = 11, HudManager.ITEM_SLOTS do
		HudManager["ItemFrame"..ID] = ItemFrame.new(HudManager.InventoryFrame.Frame, ID, math.random(100000, 999999))
	end

end

return HudManager
