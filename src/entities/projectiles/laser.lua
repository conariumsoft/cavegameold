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


local function sign(n)
    return n > 0 and 1 or n < 0 and -1 or 0
end

local function check_intersect(l1p1, l1p2, l2p1, l2p2)
    local function check_dir(pt1, pt2, pt3) return sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end

    return (check_dir(l1p1, l1p2, l2p1) ~= check_dir(l1p1, l1p2, l2p2)) and (check_dir(l2p1, l2p2, l1p1) ~= check_dir(l2p1, l2p2, l1p2))
end


local function find_intersect(l1p1, l1p2, l2p1, l2p2, seg1, seg2)
    local a1, b1, a2, b2 = l1p2.y-l1p1.y, l1p1.x - l1p2.x, l2p2.y - l2p1.y, l2p1.x - l2p2.x

    local c1, c2 = a1*l1p1.x+b1*l1p1.y, a2*l2p1.x+b2*l2p1.y
    local det, x, y = a1*b2 - a2*b1

    if det == 0 then return false end

    x, y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
    if seg1 or seg2 then
        local min, max = math.min, math.max

        if seg1 and not (min(l1p1.x, l1p2.x) <= x and x <= max(l1p1.x, l1p2.x) and min(l1p1.y, l1p2.y) <= y and y <= max(l1p1.y, l1p2.y)) or
           seg2 and not (min(l2p1.x, l2p2.x) <= x and x <= max(l2p1.x, l2p2.x) and min(l2p1.y, l2p2.y) <= y and y <= max(l2p1.y, l2p2.y)) then
            return false
        end
    end
    return x, y

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

                    local ep1 = entity.position + jutils.vec2.new(-entity.boundingbox.x, -entity.boundingbox.y)
                    local ep2 = entity.position + jutils.vec2.new(-entity.boundingbox.x, entity.boundingbox.y)
                    local ep3 = entity.position + jutils.vec2.new(entity.boundingbox.x, -entity.boundingbox.y)
                    local ep4 = entity.position + jutils.vec2.new(entity.boundingbox.x, entity.boundingbox.y)

                    local topl    = check_intersect(self.p1, self.p2, ep1, ep3)
                    local bottoml = check_intersect(self.p1, self.p2, ep2, ep4)
                    local leftl   = check_intersect(self.p1, self.p2, ep1, ep2)
                    local rightl  = check_intersect(self.p1, self.p2, ep3, ep4)

                    if topl or bottoml or leftl or rightl then
                        entity:damage(10)
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