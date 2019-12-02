local entity = require("src.entities.entity")

local tileentity = entity:subclass("TileEntity")

function tileentity:init(positions)
	entity.init(self)
	self.tilepositions = positions
end

function tileentity:isAtTile(wx, wy)
	for _, pos in pairs(self.tilepositions) do
		if wx == pos[1] and wy == pos[2] then
			return true
		end
	end
	return false
end

function tileentity:update(dt)
	entity.update(self, dt)
end


return tileentity