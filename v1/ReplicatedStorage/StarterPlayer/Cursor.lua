local UIS = game:GetService("UserInputService")
local Cursor = {
	UIObjectSelected = nil,
	UIObjectHovering = nil,
}

function Cursor.Get3DPosition()

end

function Cursor.Get2DPosition()
	local mousePosition = UIS:GetMouseLocation()
	return UDim2.new(0, mousePosition.X, 0, mousePosition.Y)
end

function Cursor.MouseMoved(x, y)
	if Cursor.UIObjectSelected then
		Cursor.UIObjectSelected.Frame.Position = UDim2.new(0,x,0,y)
	end
end

function Cursor.Raycast()

end

--Cursor.MouseButton1 = {
--	function()
--		print("mousedown")
--		if not Cursor.UIObjectHovering then return end
		
--		local draggingFrame = Cursor.UIObjectHovering.DraggingFrame
		
--		Cursor.UIObjectSelected = {
--			OriginalSize = draggingFrame.Size,
--			OriginalPosition = draggingFrame.Position,
--			OriginalParent = draggingFrame.Parent,
--			Frame = draggingFrame
--		}
		
--		local absoluteSize = draggingFrame.AbsoluteSize
--		draggingFrame.Size = UDim2.new(0,draggingFrame.AbsoluteSize.X,0,draggingFrame.AbsoluteSize.Y)
		
--		draggingFrame.Parent = _G.Hud
--		draggingFrame.Position = Cursor.Get2DPosition()
		
--		local frameSize = draggingFrame.Size
--		local sizeX = frameSize.X.Offset
--		local sizeY = frameSize.Y.Offset
		
--		Cursor._mouseMovedEvent = UIS.InputChanged:Connect(function(input, gameProcessed)
--			if input.UserInputType == Enum.UserInputType.MouseMovement then
--				local x = input.Position.X -- sizeX/2
--				local y = input.Position.Y -- sizeY/2
--				_G.Cursor.MouseMoved(x, y)
--			end
--		end)
--	end,
	
--	function()
--		print("mouseup")
--		if not Cursor.UIObjectSelected then return end
--		Cursor._mouseMovedEvent:Disconnect()
		
--		local frame = Cursor.UIObjectSelected.Frame
		
--		frame.Position = Cursor.UIObjectSelected.OriginalPosition
--		frame.Size = Cursor.UIObjectSelected.OriginalSize
--		frame.Parent = Cursor.UIObjectSelected.OriginlParent
--		Cursor.UIObjectSelected = nil
--	end,
--}
--function Cursor.MouseButton1()
	
--end

function Cursor.MouseButton2()

end

function Cursor.MouseButton3()

end

function Cursor.Init()
	
end

return Cursor
