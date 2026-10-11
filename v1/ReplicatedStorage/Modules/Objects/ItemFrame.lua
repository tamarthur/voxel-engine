local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Util = Modules.Util

local Viewport = require(Modules.Objects.Viewport)

local ItemFrame = {}--require(Util.InstanceWrapper)()
ItemFrame.__index = ItemFrame

function ItemFrame:_setUpClickedEvent()
	self._clickedEvent = self.Button.MouseButton1Click:Connect(function(...)
		self:Activate(...)
	end)	
end

function ItemFrame:_setUpDragEvents()
	self._dragStartEvent = self.Button.MouseButton1Down:Connect(function(...)
		self:_mouseButton1Down(...)
	end)	

	self._dragEndEvent = self.Button.MouseButton1Up:Connect(function(...)
		self:_mouseButton1Up(...)
	end)	
end

function ItemFrame:_setUpUIEvents()
	self._mouseEnterEvent = self.Button.MouseEnter:Connect(function(...)
		self:_mouseEnter(...)
	end)	

	self._mouseLeaveEvent = self.Button.MouseLeave:Connect(function(...)
		self:_mouseLeave(...)
	end)	

	if not self.Item then return end
	self:_setUpClickedEvent()
end

function ItemFrame:_disconnectUIEvents()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
end

function ItemFrame:_mouseEnter()
	_G.Cursor.UIObjectHovering = self
	--print(_G.Cursor.UIObjectHovering)
end

function ItemFrame:_mouseLeave()
	if _G.Cursor.UIObjectHovering == self then
		_G.Cursor.UIObjectHovering = nil
	end
	--print(_G.Cursor.UIObjectHovering)
end

function ItemFrame:_mouseButton1Down()
	--print("Dragging start")
	if not self.Item or self._draggingEvent then return end
	
	local frameSize = self._frame.Size
	local button = self.Button
	
	button.Size = self._frame.Size
	button.Parent = _G.Hud
	
	local function setFramePosition(x,y)
		button.Position =  UDim2.new(0, x, 0, y)
	end
	
	setFramePosition(UIS:GetMouseLocation().X , UIS:GetMouseLocation().Y - frameSize.Y.Offset/2)
	
	self._draggingEvent = game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setFramePosition(input.Position.X, input.Position.Y)
		end
	end)
end

function ItemFrame:_mouseButton1Up()
	--print("Dragging end")
	if not self.Item or not self._draggingEvent then return end
	self._draggingEvent:Disconnect()
	self._draggingEvent = nil
	self.Button.Parent = self._frame
	self.Button.Position = UDim2.new(.5,0,.5,0)
	self.Button.Size = UDim2.new(1,0,1,0)
	local hoveringFrame = _G.Cursor.UIObjectHovering
	if hoveringFrame and hoveringFrame ~= self then
		self:_swapItems(hoveringFrame)
	end
end

function ItemFrame:_swapItems(otherFrame)
	local otherImage = otherFrame.Image
	local otherItem = otherFrame.Item
	
	otherFrame.Item = self.Item
	otherFrame.Image = self.Image
	if otherFrame.Image then
		otherFrame.Image.Parent = otherFrame.Button
		otherFrame.Button.Text = ""
	else
		otherFrame.Button.Text = otherFrame.Item or ""
	end
	
	self.Item = otherItem
	self.Image = otherImage
	if self.Image then
		self.Image.Parent = self.Button
		self.Button.Text = ""
	else
		self.Button.Text = self.Item or ""
	end
end

function ItemFrame.new(parent, ID, item, key)
	local frame = ReplicatedStorage.UI.ItemFrame:Clone()
	frame.Name = ID
	frame.Key.Text = key or ""
	frame.Parent = parent
	
	local self = setmetatable({
		Button = frame.Button,
		Item = item,
		
		_frame = frame,
	}, ItemFrame)
	
	self:_setUpUIEvents()
	
	if not item then
		return self
	end
	
	local model = workspace.Interactive:FindFirstChild(item)
	if model then
		local viewport = Viewport.new(self.Button, model)
		viewport.FieldOfView = 0
		viewport:Enable()
		self.Image = viewport
		
	else
		self.Button.Text = item
	end
	return self
end

function ItemFrame:EnableDragging()
	if not self.Item then return end
	self._clickedEvent:Disconnect()
	self:_setUpDragEvents()
end

function ItemFrame:DisableDragging()
	if not self.Item then return end
	self._dragStartEvent:Disconnect()
	self._dragEndEvent:Disconnect()
	_G.Cursor.UIObjectHovering = nil
	self:_mouseButton1Up()
	self:_setUpClickedEvent()
end

function ItemFrame:Show()
	if self._frame.Visible then return end
	self._frame.Visible = true
	self:_setUpUIEvents()
end

function ItemFrame:Hide()
	if not self._frame.Visible then return end
	self._frame.Visible = false
	self._mouseEnterEvent:Disconnect()
	self._mouseLeaveEvent:Disconnect()
	self:DisableDragging()
end

function ItemFrame:Activate()
	--self.test()
	print(self._frame.Name)
end

function ItemFrame:RemoveItem()
	self.Item = nil
	self.Button.Text = nil
	if self.Image then
		self.Image:Destroy()
	end
end

function ItemFrame:Destroy()
	self._clickedEvent:Disconnect()
	self._mouseEnterEvent:Disconnect()
	self._mouseLeaveEvent:Disconnect()
	self:DisableDragging()
	
	self.Image:Destroy()
	self._frame:Destroy()
	setmetatable(self, nil)
end

return ItemFrame
