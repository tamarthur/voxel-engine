local EditableMesh = game:GetService("AssetService"):CreateEditableMeshAsync(script.Parent.MeshId)
EditableMesh.Parent = script.Parent

local Verticies = EditableMesh:GetVertices()
local VerticiesPositions = {}

for _, vertexID in Verticies do
	VerticiesPositions[vertexID] = EditableMesh:GetPosition(vertexID)
end

local timer = 0

while true do
	task.wait()
	for vertexID, position in pairs(VerticiesPositions) do
		EditableMesh:SetPosition(vertexID, position + Vector3.new(math.sin(position.Y*10 + timer)/10, 0, 0))
	end
	timer += 1/10
end
