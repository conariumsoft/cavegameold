local guiutil = require("src.guiutil")

local physicalentity = require("src.entities.physicalentity")


local boss = physicalentity:subclass("Boss")

function boss:init()
    physicalentity.init(self)

    self.mass = 0
    self.xfriction = 1
    self.noclip = true
    self.apply_gravity = false
    self.boss_title = "boss"
end

function boss:update(dt)

    physicalentity.update(self, dt)
end

function boss:draw()
    physicalentity.draw(self)
    -- TODO: draw boss healthbar

    love.graphics.push()
    love.graphics.origin()

    love.graphics.setFont(guiutil.fonts.font_20)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(self.boss_title, 0, 10, love.graphics.getWidth(), "center")

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill",
        80, 40, love.graphics.getWidth()-160, 20
    )

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 
        80, 40, (love.graphics.getWidth()-160)*(self.health/self.maxhealth), 20
    )

    love.graphics.setColor(1,1,1)
    love.graphics.printf(self.health.."/"..self.maxhealth, 0, 40, love.graphics.getWidth(), "center")

    love.graphics.pop()
end

return boss