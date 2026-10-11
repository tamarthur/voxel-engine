local loading = true
local progress = script.Parent.Frame.Progress
local label = script.Parent.TextLabel

local progressEvent
progressEvent = game.ReplicatedStorage:WaitForChild("LoadPercent").Changed:Connect(function(value)
	progress.Size = UDim2.new(game.ReplicatedStorage.LoadPercent.Value,0,1,0)
end)

local event
event = game.Players.LocalPlayer.CharacterAdded:Connect(function()
	loading = false
	progressEvent:Disconnect()
	event:Disconnect()
end)

local texts = {
	"Generating World",
	"Layering grass",
	"Adding ores",
	"Filling oceans",
	"Adding biomes",
}

local textDelay = .3

while loading do
	for i = 1, math.random(2, 3) do
		local text = texts[math.random(1,#texts)]
		label.Text = text
		task.wait(textDelay)
		label.Text = text.."."
		task.wait(textDelay)
		label.Text = text..".."
		task.wait(textDelay)
		label.Text = text.."..."
		task.wait(textDelay)
	end
end

script.Parent:Destroy()
