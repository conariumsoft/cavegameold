local jutils = require("src.jutils")
local boss = require("src.entities.boss")

local zeppelin_texture = love.graphics.newImage("assets/entities/airship.png")

local zeppelin = boss:subclass("Zeppelin")

function zeppelin:init()
    boss.init(self)
    self.texture = zeppelin_texture
    self.boundingbox = jutils.vec2.new(96, 30)
    self.textureorigin = jutils.vec2.new(96, 30)
    self.boss_title = "Led Zeppelin"
    self.health = 500
    self.maxhealth = 500
end

function zeppelin:update(dt)
    boss.update(self, dt)
end

function zeppelin:draw()
    boss.draw(self)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.texture,
		self.position.x, self.position.y, self.rotation,
		self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return zeppelin