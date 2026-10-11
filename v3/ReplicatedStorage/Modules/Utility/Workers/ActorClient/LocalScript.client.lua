local actor = script:GetActor()

actor:BindToMessage("DoWork", function(work, ...)
	print(actor.Parent)
	work(...)
	actor.Parent = actor.Parent.Waiting
end)

actor:BindToMessageParallel("DoWorkParallel", function(work)
	
end)
