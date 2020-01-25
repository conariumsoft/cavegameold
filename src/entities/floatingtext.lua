local guiutil = require("src.guiutil")
local entity = require("src.entities.entity")


local floating_text_entity = entity:subclass("FloatingText")


function floating_text_entity:init(text, textcolor, font)

    entity.init(self)
    font = font or guiutil.fonts.font_12

    self.text = text
    self.textcolor = textcolor or {1, 0, 0}
    self.unloadtimer = 3
    self.float_up_direction = math.random(1, 3) - 2
    self.text_fade = 3
    self.float_stop_time = 0
    self.font = font
    
end

function floating_text_entity:update(dt)

    entity.update(self, dt)

    self.float_stop_time = self.float_stop_time + dt

    if self.float_stop_time < (1/2) then
        self.position.y = self.position.y - (dt*55)
        self.position.x = self.position.x + ((dt*4) *self.float_up_direction)
    end

    self.text_fade = self.text_fade - dt
end

function floating_text_entity:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.textcolor[1], self.textcolor[2], self.textcolor[3], self.text_fade)

    love.graphics.print(self.text, self.position.x, self.position.y)
    love.graphics.setFont(guiutil.fonts.default)
end

return floating_text_entity