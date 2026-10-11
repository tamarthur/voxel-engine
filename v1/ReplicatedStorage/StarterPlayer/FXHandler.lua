local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = ReplicatedStorage.FX
local FXCache = workspace.FXCache
local FXHandler = {}

function FXHandler.onFXAdded(FXConfig)
	local currentPosition = _G.Player.Character.HumanoidRootPart.Position
	local distance = (currentPosition - FXConfig:GetAttribute("Position")).Magnitude
	
	if distance <= _G.RENDER_DISTANCE then
		require(FX:FindFirstChild(FXConfig.Name))(FXConfig)
	end
end

function FXHandler.Init()
	FXCache.ChildAdded:Connect(FXHandler.onFXAdded)
	print("FXhandler initialized")
end

return FXHandler
