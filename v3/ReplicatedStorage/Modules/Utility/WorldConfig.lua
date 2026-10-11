local config = {
	
	BLOCK_SIZE = 4,
	CHUNK_SIZE = 16,
	
	AXIS_MAP = {"x", "z", "y"},
	DIRECTION_MAP = {
		Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), 
		Vector3.new(-1, 0, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, -1)
	}
	
}

return config
