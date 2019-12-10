local entity = require("src.entities.entity")
local jutils = require("src.jutils")
local grid = require("src.grid")


local laser = entity:subclass("Laser")

function laser:init(p1, p2, timer)

    entity.init(self)

    self.p1 = jutils.vec2.new(p1.x, p1.y)
    self.p2 = jutils.vec2.new(p2.x, p2.y)

    self.timer = timer
end

function laser:update(dt)
    entity.update(self, dt)

    self.timer = self.timer - dt

    if self.timer < -(0.25) then
        self.dead = true
    end

    local dist = self.p1:distance(self.p2)

    love.graphics.setColor(0.75, 0.95, 1)
    for i = 1, dist, 8 do
        local pos = self.p1:lerp(self.p2, i/dist)

        local tx, ty = grid.pixelToTileXY(pos.x, pos.y)
        self.world:setLight(tx, ty, 0.5, 1, 2)


        for _, entity in pairs(self.world.entities) do
            if entity ~= self then
                if entity:isA("Zombie") or entity:isA("Flower") then
                    if pos.x - entity.position.x < entity.boundingbox.x and pos.y - entity.position.y < entity.boundingbox.y then
                        entity:damage(50)
                    end
                end
            end
        end
    end
end

function laser:draw()
    if self.timer > 0 then return end
    love.graphics.setColor(0.5, 0.75, 1)
    love.graphics.setLineWidth(0.75)

    love.graphics.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)

    local dist = self.p1:distance(self.p2)
    love.graphics.setLineWidth(1.25)
    love.graphics.setColor(0.75, 0.95, 1)
    for i = 1, dist do
        local pos = self.p1:lerp(self.p2, i/dist)
        love.graphics.line(pos.x, pos.y, pos.x+math.random(12)-6, pos.y+math.random(12)-6)
    end
end

return laser