local jutils = require("src.jutils")
local input = require("src.input")

baseitem:new("PURPLE_STAFF", {
    displayname = "MAGIC STAFF",
    texture = "purplestaff.png",
    stack = 1,
    rarity = 2,
    speed = 0.1,
    animation = {
        love.graphics.newQuad(0, 0, 8, 8, 24, 8),
        love.graphics.newQuad(8, 0, 8, 8, 24, 8),
        love.graphics.newQuad(16, 0, 8, 8, 24, 8),
    },
    inWorldScale = 2,
    playeranim = pointanim(true),
    defaultRotation = math.rad(45),
    animationspeed = 6,
    repeating = false,
    playerHoldPosition = jutils.vec2.new(0, 8),
    use = function(self, player)
        player.itemdata.warmup = 0
        return true
    end,
    usestep = function(self, player, dt)
        player.itemdata.warmup = player.itemdata.warmup + dt
        player.animation.timer = 0.05
        if player.mouse.down == false then
            return true
        end
        return false
    end,

    useend = function(self, player)
        local power = player.itemdata.warmup

        power = math.min(power, 3) -- max charge of 3 seconds

        if power > 1 then
            local world = player.world
            local unit = (jutils.vec2.new(input.getTransformedMouse())-player.position):unitvec()
            local proj = world:addEntity("magicball", player.position + unit*16, jutils.vec2.new(input.getTransformedMouse()), 80, 0, player)

            proj.power = power
        end

        player.itemdata = {}
    end
})