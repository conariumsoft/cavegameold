local jutils = require("src.jutils")

local physicalentity = require("src.entities.physicalentity")

local skull_texture = love.graphics.newImage("assets/entities/skull.png")

local skull = physicalentity:subclass("Skull")

function skull:init()

    physicalentity.init(self)

    self.mass = 0
    self.texture = skull_texture
    self.textureorigin = jutils.vec2.new(16, 16)
    self.boundingbox = jutils.vec2.new(16, 16)
    self.direction = -1
end

function skull:update(dt)
    physicalentity.update(self, dt)
end

function skull:draw()
    physicalentity.draw(self)

    love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x* (-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return skull