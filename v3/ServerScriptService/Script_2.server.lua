local a = {}

function test(b)
	b[1] = 2
end

test(a)
print(a)
