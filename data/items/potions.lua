local jutils = require("src.jutils")

local potion = consumable:subclass("Potion") do
    potion.playeranim = swinganim(0, -45)
    potion.playerHoldPosition = jutils.vec2.new(4, 4)
    potion.defaultRotation = math.rad(0)
    potion.stack = 30
    potion.repeating = false
    potion.speed = 1
    potion.inWorldScale = 1
    potion.texture = love.graphics.newImage("assets/items/fullbottle1.png")
    potion.use = function(self, player)
        local result = self:consume(player)
    
        if result == true then
            --TODO: play drinking sfx
            local stack = player.itemHoldingStack
            stack[2] = stack[2]-1
            return true
        end
    end
end

potion:new("MANLET_POTION", {
    displayname = "MANLET POTION",
    color = {0.5, 1, 0.5},
    texture = "fullbottle1.png",
    rarity = 5,
    tooltip = "Temporary shrinkage in a bottle.\nDuration: 60 seconds",
    consume = function(self, player)
        player:addStatusEffect("MANLET", 60)
        return true
    end,
})


potion:new("SPEED_POTION", {
    displayname = "QUICKFOOT POTION",
    color = {0.5, 0.5, 1},
    texture = "fullbottle2.png",
    rarity = 4,
    tooltip = "\"Velocity increase guaranteed, or your money back!\"\nDuration: 60 seconds",
    consume = function(self, player)
        player:addStatusEffect("ACCELLERATION", 60)
        return true
    end,
})

potion:new("LOWMASS_POTION", {
    displayname = "WEIGHT LOSS SERUM",
    color = {1, 0.25, 0.25},
    texture = "fullbottle3.png",
    rarity = 4,
    tooltip = "\"DANGER: Do not mix with caffeine!\"Duration: 60 seconds",
    consume = function(self, player)
        player:addStatusEffect("LOWMASS", 60)
        return true
    end,
})

potion:new("ENERGY_DRINK", {
    displayname = "YEET(tm) ENERGY DRINK",
    color = {1, 1, 0.25},
    texture = "fullbottle2.png",
    rarity = 4,
    tooltip = "\"Not safe for human consumption\"",
    consume = function(self, player)
        player:addStatusEffect("EXPLOSION", 5)
        return true
    end,
})

potion:new("HEALING_POTION", {
    displayname = "GENERIC HEALTH POTION",
    color = {1, 0.5, 1},
    texture = "fullbottle1.png",
    rarity = 2,
    tooltip = "Restores 5 HP/second.\nDuration 10 seconds.",
    consume = function(self, player)
        player:addStatusEffect("HEAL", 10)
        return true
    end,
})