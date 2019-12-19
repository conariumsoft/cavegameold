local jutils = require("src.jutils")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local input = require("src.input")
local grid = require("src.grid")
local collision = require("src.collision")

local function getPlayerTile(playerentity)
	local pos = playerentity.position

	return grid.pixelToTileXY(pos.x, pos.y)
end

local function magnitude(x1, y1, x2, y2)
	return math.sqrt( (x2 - x1)^2 + (y2-y1)^2 )
end

baseitem:new("BULLET", {
    stack = 999,
    tooltip = ""
})

baseitem:new("SILVER_BULLET", {
    stack = 999,
    tooltip = ""
})

baseitem:new("FRAGMENT_BULLET", {
    stack = 999,
    tooltip = ""
})

baseitem:new("HOLY_BULLET", {
    stack = 999,
    tooltip = ""
})

baseitem:new("NANOBULLET", {
    stack = 999,
    tooltip = ""
})

baseitem:new("FLINTLOCK", {
    displayname = "FLINTLOCK PISTOL",
    speed = 0.6,
    texture = "flintlock.png",
    tooltip = "work in progress bruh",
    stack = 1,
    playeranim = pointanim(true),
    inWorldScale = 2,
    defaultRotation = math.rad(90),
    playerHoldPosition = jutils.vec2.new(0, 4),
    use = function(self, player)

        local unit = (jutils.vec2.new(input.getTransformedMouse())-player.position):unitvec()

        local summonPos = player.position + unit*16

        if player.gui.inventory:hasItem(itemlist.BULLET.id, 1) then
            player.gui.inventory:removeItem(itemlist.BULLET.id, 1)
            local bullet = player.world:addEntity("bullet", summonPos, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
            return true
        end

        if player.gui.inventory:hasItem(itemlist.SILVER_BULLET.id, 1) then
            player.gui.inventory:removeItem(itemlist.SILVER_BULLET.id, 1)
            -- todo: silver bullet spawning
            local bullet = player.world:addEntity("bullet", summonPos, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
            return true
        end

        if player.gui.inventory:hasItem(itemlist.NANOBULLET.id, 1) then
            player.gui.inventory:removeItem(itemlist.NANOBULLET.id, 1)
            -- todo: nanobullet spawning
            local bullet = player.world:addEntity("bullet", summonPos, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
            return true
        end

        if player.gui.inventory:hasItem(itemlist.HOLY_BULLET.id, 1) then
            player.gui.inventory:removeItem(itemlist.HOLY_BULLET.id, 1)
            -- todo: holy bullet spawning
            local bullet = player.world:addEntity("bullet", summonPos, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
            return true
        end

        if player.gui.inventory:hasItem(itemlist.FRAGMENT_BULLET.id, 1) then
            player.gui.inventory:removeItem(itemlist.FRAGMENT_BULLET.id, 1)
            -- todo: holy bullet spawning
            local bullet = player.world:addEntity("bullet", summonPos, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
            return true
        end

    end
})




baseitem:new("ARROW", {
    displayname = "ARROW",
    stack = 300,

})

baseitem:new("BOW", {
    displayname = "TEST BOW",
    speed = 1/2,
    texture = "bow.png",
    playeranim = pointanim(true),
    inWorldScale = 2,
    stack = 1,
    use = function(self, player)

        -- TODO: consume arrow from player inventory
        if player.gui.inventory:hasItem(itemlist.ARROW.id, 1) then
            player.gui.inventory:removeItem(itemlist.ARROW.id, 1)

            local unit = (jutils.vec2.new(input.getTransformedMouse())-player.position):unitvec()
            local arrow = player.world:addEntity("arrow")
            arrow:teleport(player.position)
            arrow.velocity = unit*350
             
            return true
        end
    
    end,
})


consumable:new("BOMB", {
    texture = "bomb.png",
    stack = 999,
    speed = 1/2,
    consume = function(self, player)
        local mx, my = input.getTransformedMouse()

        local tx, ty = grid.pixelToTileXY(mx, my)
        local px, py = getPlayerTile(player)

        local world = player.world

        local bombentity = world:addEntity("bombentity", 5, player)
        bombentity:teleport(player.position)
        local mousepos = jutils.vec2.new(mx, my)
        local unitvec = (mousepos - player.position):unitvec()
        bombentity.velocity = unitvec*400

        return true
    end,
})

consumable:new("STICKY_BOMB", {
    texture = "stickybomb.png",
    stack = 999,
    speed = 1/2,
    consume = function(self, player)
        local mx, my = input.getTransformedMouse()

        local tx, ty = grid.pixelToTileXY(mx, my)
        local px, py = getPlayerTile(player)


        local world = player.world

        local bombentity = world:addEntity("stickybomb", 5, player)
        bombentity:teleport(player.position)
        local mousepos = jutils.vec2.new(mx, my)
        local unitvec = (mousepos - player.position):unitvec()
        bombentity.velocity = unitvec*400
        return true
    end,
})

consumable:new("DYNAMITE", {
    
})


local SWORD_TOOLTIP = 
[[
{speed} Speed
{knockback} Knockback
{range} Range
{damage} Atk Damage
]]

local function swordUse(self, player)
    -- figure out hitbox overlaps
    
    return true

end

local function swordUseStep(self, player, dt)
    local percent = 1-(player.animation.timer/self.speed)
    if percent > 0.5 then percent = 1-percent end
    percent = percent * 2
    --print(percent)

    local world = player.world

    for _, entity in pairs(world.entities) do
        if entity ~= player and entity.hostile then
            local pos = entity.position
            local box = entity.boundingbox

            local px = player.position.x

            if player.direction == -1 then
                px = px - (self.range*percent)
            end
            if collision.aabb(px, player.position.y-1, self.range*percent, 2, pos.x, pos.y, box.x, box.y) then
                local finaldamage = self.damage
                local variation = (math.random()-0.5)*5
                finaldamage = finaldamage + variation
                local crit = math.random()
                if crit > 0.95 then
                    finaldamage = finaldamage*2
                end

                if entity.invulnerability <= 0 then
                    entity:damage(finaldamage)

                    entity.velocity.x = entity.velocity.x + (player.direction*self.knockback)
                    --entity.velocity.y = -20
                end
            end
        end
    end
    if player.animation.running == false then return true end

end

local function swordUseEnd(self, player)

end


baseitem:new("RUSTY_SWORD", {
    displayname = "RUSTY SWORD",
    speed = 1/4,
    texture = "sword.png",
    color = {0.7, 0.4, 0.3},
    tooltip = SWORD_TOOLTIP,
    stack = 1,
    inWorldScale = 2,
    repeating = false,
    playeranim = jabanim(false, 20),
    playerHoldPosition = jutils.vec2.new(0, 8),
    defaultRotation = math.rad(45),
    knockback = 30,
    damage = 5,
    range = 20,
    holdbegin = function(self, player)

    end,
    holdend = function(self, player)

    end,
    use = swordUse,
    usestep = swordUseStep,
    useend = swordUseEnd,
        
})

baseitem:new("IRON_SWORD", {
    displayname = "IRON SWORD",
    speed = 1/6,
    texture = "sword.png",
    color = {0.9, 0.8, 0.8},
    tooltip = SWORD_TOOLTIP,
    stack = 1,
    inWorldScale = 2,
    playeranim = jabanim(false, 20),
    playerHoldPosition = jutils.vec2.new(0, 8),
    defaultRotation = math.rad(45),
    knockback = 50,
    damage = 8,
    range = 20,
    holdbegin = function(self, player)

    end,
    holdend = function(self, player)

    end,
    use = swordUse,
    usestep = swordUseStep,
    useend = swordUseEnd,
})

baseitem:new("PUNCHY", {
    displayname = "BLUESTEEL BRASS",
    speed = 1/2,
    texture = "punchy.png",
    stack = 1,
    rarity = 3
})