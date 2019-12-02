local guiutil = require("src.guiutil")
local entity = require("src.entities.entity")


local floating_text_entity = entity:subclass("FloatingText")


function floating_text_entity:init(text, textcolor)

    entity.init(self)

    self.text = text
    self.textcolor = textcolor or {1, 0, 0}
    self.unloadtimer = 3
    self.float_up_direction = math.random(1, 3) - 2
    self.text_fade = 3
    
end

function floating_text_entity:update(dt)

    entity.update(self, dt)

    self.position.y = self.position.y - (dt*15)
    self.position.x = self.position.x + ((dt*3) *self.float_up_direction)

    self.text_fade = self.text_fade - dt
end

function floating_text_entity:draw()
    love.graphics.setFont(guiutil.fonts.font_12)
    love.graphics.setColor(self.textcolor[1], self.textcolor[2], self.textcolor[3], self.text_fade)

    love.graphics.print(self.text, self.position.x, self.position.y)
    love.graphics.setFont(guiutil.fonts.default)
end

return floating_text_entity