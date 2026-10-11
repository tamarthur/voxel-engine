local WorldBuilder = require(game.ReplicatedStorage.Modules.Utility.WorldBuilder)
print(WorldBuilder:BlockIndexToBlockPosition(Vector3.new(1,1,1), Vector3.new(1,1,1)))

print(WorldBuilder:BlockIndexToBlockPosition(Vector3.new(1,1,1), Vector3.new(1,2,1)))
