local Workers = {}
Workers.__index = Workers

function Workers.new(cores)
	local actorTemplate = game:GetService("RunService"):IsClient() and script.ActorClient or script.ActorServer
	
	local self = setmetatable({}, Workers)
	local team = Instance.new("Folder", workspace.Workers)

	self.Working = Instance.new("Folder", team)
	self.Working.Name = "Working"
	self.Waiting = Instance.new("Folder", team)
	self.Waiting.Name = "Waiting"
	
	for i = 1, cores do
		local actor = actorTemplate:Clone()
		actor.Name = "Actor"
		actor.Parent = self.Waiting
	end
	return self
end

function Workers:DoWork(work)
	local actor = self.Waiting:FindFirstChild("Actor")
	if not actor then
		self.Waiting.ChildAdded:Wait()
		actor = self.Waiting.Actor
	end
	actor.Parent = self.Working
	actor:SendMessage("DoWork", work)
end

function Workers:Destroy()
	
end

return Workers
