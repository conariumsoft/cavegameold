local arrow = require("src.entities.projectiles.arrow")

local flaming_arrow = arrow:subclass("FlamingArrow")

local flaming_arrow_texture = love.graphics.newImage("assets/entities/flaming_arrow.png")

function flaming_arrow:init()
    arrow.init(self)

    self.texture = flaming_arrow_texture
end

function flaming_arrow:entityCollision(entity, sep_vec, norm_vec)
    if self.cooldown < 0 then
        local damage = math.random(8, 15)

        self.health = self.health - damage
        entity:damage(damage)
        if entity:isA("Humanoid") then
            entity:addStatusEffect("BURNING", 2)
        end
        self.cooldown = 0.04
    end
end

return flaming_arrow