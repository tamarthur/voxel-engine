--!strict
local Types = {}

--export type Block = {
--	ID: number,
--	Color: Color3 | nil,
--}

export type ChunkInstance = typeof(setmetatable(
	{} :: {
		Data	: {number},
		Position: Vector3
	}, 
	{} :: {
		__index 		: typeof(getmetatable(({}::ChunkInstance))),
		_createBlock	: (self: ChunkInstance) -> Part,
		_toIndex	: (self: ChunkInstance, x: number, y: number, z: number) -> number,
		Set 			: (self: ChunkInstance, x: number, y: number, z: number, id: number) -> (),
		Get				: (self: ChunkInstance, x: number, y: number, z: number) -> number,
		Iterate 		: (self: ChunkInstance, callback: (x: number, y: number, z: number) -> ()) -> (),
		Load			: (self: ChunkInstance) -> ()
	}))

return Types
