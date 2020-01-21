local jutils = require("src.jutils")

local humanoid = require("src.entities.humanoid")


local caster = humanoid:subclass("Caster")

local casterTexture = love.graphics.newImage("assets/entities/caster.png")

function caster:init()
	humanoid.init(self)

	self.boundingbox = jutils.vec2.new(12, 18)
	self.textureorigin = jutils.vec2.new(12, 18)


	self.displayname = "Caster"
	self.hurt_yell_pitch = 1.25
	self.texture = casterTexture
	
	self.mass = 1
	self.maxhealth = 30
	self.health = 30
	self.stun = 0
	self.jump_wait = 0

end

function caster:update(dt)
	humanoid.update(self, dt)
end

function caster:draw()

	love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x * (-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)

	humanoid.draw(self)
end

return caster
