local jutils = require("src.jutils")


local entity = require("src.entities.entity")


local swatter = entity:subclass("swatter")

function swatter:init(tilepos)
	entity.init(self)


	self.anchor_position = jutils.vec2.new(0, 0)

	self.segment_length = 10
	self.segments = {
		0,
		45,
		45,
		45,
	}

end

function swatter:update(dt)

end

function swatter:draw()


	local px, py = self.anchor_position.x*8, self.anchor_position.y*8


	love.graphics.setColor(0, 0, 1)
	love.graphics.setPointSize(2)

end



return swatter