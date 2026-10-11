local DraggableFrame = {}
DraggableFrame.__index = DraggableFrame

function DraggableFrame:_mouseButton1Down()
	local frameSize = self._frame.Size
	local sizeX = frameSize.X.Offset
	local sizeY = frameSize.Y.Offset

	self._frame.ZIndex = 2
	local viewportSize = self._frame.Frame.AbsoluteSize
	self._frame.Size = UDim2.new(0,viewportSize.X,0,viewportSize.Y)
	self._frame.Parent = _G.Hud

	local function setFramePosition(x,y)
		self._frame.Position =  UDim2.new(0, x, 0, y)
	end

	setFramePosition(_G.UserInputService:GetMouseLocation().X - sizeX/2, _G.UserInputService:GetMouseLocation().Y - sizeY)

	self._draggingEvent = game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local x = input.Position.X - sizeX/2
			local y = input.Position.Y - sizeY/2
			setFramePosition(x, y)
		end
	end)
end

function DraggableFrame:_mouseButton1Up()
	self._frame.ZIndex = 1
	if self._draggingEvent then
		self._draggingEvent:Disconnect()
		self._draggingEvent = nil
		self._frame.Parent = self._parent
		self._frame.Position = self.OriginalPosition
		self._frame.Size = self.OriginalSize
	end
end

function DraggableFrame:_setUpDragEvents()
	self._dragStartEvent = self._frame.MouseButton1Down:Connect(function(...)
		self:_mouseButton1Down(...)
	end)	

	self._dragEndEvent = self._frame.MouseButton1Up:Connect(function(...)
		self:_mouseButton1Up(...)
	end)	
end

function DraggableFrame.new(frame, parent)
	local self = {
		_frame = frame,
		_parent = parent,
		OriginalSize = frame.Size,
		OriginalPosition = frame.Position,
	}
	return setmetatable(self,DraggableFrame)
end

function DraggableFrame:Disable()
	self._dragStartEvent:Disconnect()
	self._dragEndEvent:Disconnect()

	self:_mouseButton1Up()
end

function DraggableFrame:Enable()
	self:_setUpDragEvents()
end

return DraggableFrame
