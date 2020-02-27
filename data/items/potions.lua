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

potion:new("GLOWING_POTION", {
	displayname = "BIOLUMINESCENT FLUID",
	color = {0.25, 0.65, 1},
	texture = "fullbottle1.png",
	rarity = 3,
	tooltip = "Genetically modified bacteria that makes you glow in the dark!",
	consume = function(self, player)
		player:addStatusEffect("GLOWING", 120)
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

-- TODO: make some new textures for these
potion:new("INSTANT_HP_10", {
	displayname = "INSTANT HEALTH VIAL",
	color = {1, 0.2, 0.5},
	texture = "fullbottle1.png",
	rarity = 1,
	tooltip = "'Tastes like chemical grapes'\nRestores 10 HP.",
	consume = function(self, player)
		player.health = player.health + 10
		return true
	end,
})

potion:new("INSTANT_HP_50", {
	displayname = "INSTANT HEALTH II VIAL",
	color = {1, 0.5, 1},
	texture = "fullbottle1.png",
	rarity = 1,
	tooltip = "'A rejuvenating brew of heavy metals, amphetamines, and opium!'\nRestores 50 HP.",
	consume = function(self, player)
		player.health = player.health + 50
		return true
	end,
})
