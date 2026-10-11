local UIS = game:GetService("UserInputService")
local InputController = {}

function InputController.Rebind(oldKey, newKey, handler)
	InputController.Keybinds[handler][newKey] = InputController.Keybinds[handler][oldKey]
	InputController.Keybinds[handler][oldKey] = nil
end

function InputController.SaveKeybinds()

end

function InputController.GetKeybinds(handler)
	return InputController.Keybinds[handler]
end

function InputController.KeyCodeToString(keyCode)
	if keyCode.Value < 127 and keyCode.Value > 33 then --// excluding space (32) character
		return string.char(keyCode.Value):upper()
	else
		return keyCode.Name --// just return keycode name if not within range
	end
end

function InputController.Init()

	InputController.Keybinds = {
		HudManager = {
			["1"] = "Hotbar1",
			["2"] = "Hotbar2",
			["3"] = "Hotbar3",
			["4"] = "Hotbar4",
			["5"] = "Hotbar5",
			["6"	] = "Hotbar6",
			["7"] = "Hotbar7",
			["8"] = "Hotbar8",
			["9"] = "Hotbar9",
			["0"	] = "Hotbar0",
			
			["`"] = "ToggleInventory",
		},
		Character = {
			["Space"] 	= "Jump",
			["Q"]		= "Dash",
			--[Enum.UserInputType.MouseButton1] 	= "test",
		},
		--Cursor = {
		--	[Enum.UserInputType.MouseButton1] 	= "MouseButton1"
		--}
	}
	
	--InputController.UIInput = {
	--	Cursor = {
	--		[Enum.UserInputType.MouseButton1] 	= "MouseButton1",
	--		--[Enum.UserInputType.MouseButton2] 	= "MouseButton2",
	--		--[Enum.UserInputType.MouseButton3] 	= "MouseButton3",
	--	},
	--}
	
	local function processInput(inputType, inputState, category)
		inputType = InputController.KeyCodeToString(inputType)
		for handler, binds in pairs(InputController[category]) do
			local inputBindName = binds[inputType]
			if not inputBindName then continue end
			
			local inputBindFunction = _G[handler][inputBindName]
			
			if type(inputBindFunction) == "function" then
				--Input is key released
				if inputState == 2 then return end
			else
				inputBindFunction = inputBindFunction[inputState]
			end
			
			if getmetatable(_G[handler]) then --if module is a class
				inputBindFunction(_G[handler], inputBindName)
			else
				inputBindFunction(inputBindName)
			end
		end
	end
	
	local function processKeyInput(inputData, inputState)
		local inputType = inputData.KeyCode
		if inputData.UserInputType ~= Enum.UserInputType.Keyboard then
			inputType = inputData.UserInputType
		end
		
		processInput(inputType, inputState, "Keybinds")
	end
	
	local function processUIInput(inputData, inputState)
		
		processInput(inputData.UserInputType, inputState, "UIInput")
		--_G.Cursor[inputData.UserInputType] = inputState
		--_G.Cursor[inputData.KeyCode] = inputState.KeyCode
	end
	
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then 
			--processUIInput(input, 1)
			return
		end
		processKeyInput(input, 1)
	end)
	
	UIS.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then 
			--processUIInput(input, 2)
			return
		end
		processKeyInput(input, 2)
	end)
	
end

return InputController
