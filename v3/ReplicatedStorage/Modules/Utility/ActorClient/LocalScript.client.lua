local actor = script:GetActor()

actor:BindToMessage("DoWork", function(work, ...)
	work(...)
end)
