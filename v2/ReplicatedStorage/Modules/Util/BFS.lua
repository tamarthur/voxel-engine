local BFS = function(queue, callback)
	local visited = {}
	local nextNode = next(queue)
	local count = 0
	while nextNode do
		count+=1
		local enqueue = callback(nextNode)
		if not enqueue then break end
		
		visited[nextNode] = true
		queue[nextNode] = nil
		
		for _, key in pairs(enqueue) do
			if visited[key] then continue end
			queue[key] = true
		end
		--task.wait()
		--print(queue)
		--if count % 1000 == 0 then
		--	print(#enqueue)
		--	print(enqueue[1], enqueue[2])
		--	task.wait()
		--end
		
		nextNode = next(queue)
	end
end

return BFS
