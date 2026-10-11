_G.Player = game.Players.LocalPlayer

local ReplicatedStorage = game.ReplicatedStorage
local Modules = ReplicatedStorage.Modules
local Util = Modules.Util
local Storage = ReplicatedStorage.Storage

_G.ClientStorage = {}

local function init(name)
	local module = game.ReplicatedStorage.StarterPlayer[name]
	_G[name] = require(module)
	_G[name].Init()
	module:Destroy()
end

local characterClient = require(game.ReplicatedStorage.Modules.CharacterClient)
_G.Character = characterClient.new(_G.Player.Character)
_G.Player.CharacterAdded:Connect(function(character)
	_G.Character = characterClient.new(character)
	init("WorldRenderer")
end)

script.Parent.Destroying:Connect(function()
	
end)


-----------------------------------
init("Cursor")
init("FXHandler")
init("InputController")
init("HudManager")
--init("ClientRequests")
--init("AnimationHandler")
--init("InputController")

------------------------------------
--wait(1)
--while task.wait() do
--	print(_G.Character.HumanoidRootPart.Velocity)
--end

--local function getModules(folder, dictionary)
--	for _, obj in ipairs(folder:GetChildren()) do
--		if obj:IsA("Folder") then
--			dictionary[obj.Name] = {}
--			getModules(obj, dictionary[obj.Name])
--			--obj:Destroy()
--		else
--			dictionary[obj.Name] = obj
--			--obj.Name = game:GetService("HttpService"):GenerateGUID()
--			--obj.Parent = game.ReplicatedStorage
--		end
--	end
--end
--getModules(game.ReplicatedStorage, _G)
