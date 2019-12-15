local humanoid = require("src.entities.humanoid")


local caster = humanoid:subclass("Caster")

local casterTexture = love.graphics.newImage("assets/entities/caster.lua")

function caster:init()
	humanoid.init(self)

	self.displayname = "Caster"
	self.hurt_yell_pitch = 1.25
	self.texture = casterTexture
	self.textureorigin = nil
	self.mass = 1
	self.maxhealth = 
	self.health = 
	self.stun = 0
	self.jump_wait = 0

end

function caster:update(dt)

end

function caster:draw()

end


return caster