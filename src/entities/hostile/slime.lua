local jutils = require("src.jutils")
local physicalentity = require("src.entities.physicalentity")

local slime = physicalentity:subclass("Slime")
local slimetexture = love.graphics.newImage("assets/entities/slime.png")

function slime:init(size)
    size = size or 1
    physicalentity.init(self)

    self.save = false
    self.texture = slimetexture
    self.boundingbox = jutils.vec2.new(8*size, 8*size)
    self.textureorigin = jutils.vec2.new(8*size, 8*size)
    
    self.direction = 1
    self.maxhealth = 10*size
    self.health = 10*size
    self.mass = 1
    self.hostile = true

    self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 16, 16, 48, 16),-- standing still
		[2] = love.graphics.newQuad(16, 0, 16, 16, 48, 16),-- walking1,
		[3] = love.graphics.newQuad(32, 0, 16, 16, 48, 16),--walking2
	--	[4] = love.graphics.newQuad(48, 0, 16, 16, 48, 16),--walking2
	}
end

function slime:updatePhysics(step)
    physicalentity.updatePhysics(self, step)

    self.velocity.x = self.velocity.x + self.direction
end

function slime:update(dt)
    physicalentity.update(self, dt)

   -- local p = self.world:getPlayer()

    --if p then

   -- end

end

function slime:draw()
    love.graphics.setColor(self.light)
    local quad = math.floor(self.age % 3) + 1
    love.graphics.draw(self.texture,
        self.animationframes[quad],
		self.position.x, self.position.y, self.rotation,
		self.scale.x*(-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return slime