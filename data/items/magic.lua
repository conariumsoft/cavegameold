local jutils = require("src.jutils")
local input = require("src.input")
local tiles = require("src.tiles")


local magic_sfx_1 = love.audio.newSource("assets/audio/iceball.ogg", "stream")

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


-- TODO: finish details of this item
baseitem:new("WICKED_FLAME", {
    displayname = "WICKED FLAME",
    texture = "scroll.png",
    stack = 1,
    rarity = 2,
    speed = 1/2,

})



baseitem:new("NIMDOC", {
    displayname = "NIMDOC",
    texture = "nimdoc.png",
    stack = 1,
    rarity = 3,
    speed = 2,
    repeating = true,
    use = function(self, player)

        local mousePos = jutils.vec2.new(input.getTransformedMouse())
        local startPos = player.position
        local direction = (mousePos-player.position):unitvec()

        local run = true
        local limiter = 12
        local decayIncrease = 0


        magic_sfx_1:stop()
        magic_sfx_1:play()

        while run == true do
            limiter = limiter - 1
            decayIncrease = decayIncrease + 0.1

            if limiter < 0 then
                run = false
                return
            end
            local result, colx, coly, sx, sy, nx, ny, tile = player.world:castRay(startPos, direction, 400, 6)

            run = result

            if result == true then

                player.world:addEntity("laser", startPos, jutils.vec2.new(colx, coly), decayIncrease)
                startPos = jutils.vec2.new(colx, coly)

                if tile == tiles.TNT.id then
                    player.world:setTileState(math.floor(colx/8), math.floor(coly/8), 1)
                end

            else
                player.world:addEntity("laser", startPos, startPos + (direction*600), decayIncrease)
            end

            if nx ~= 0 then
                direction.x = -direction.x
            end
    
            -- mirror the ray on the X axis
            if ny ~= 0 then
                direction.y = -direction.y
            end

            direction.x = direction.x + (math.random() - 0.5)/2
            direction.y = direction.y + (math.random() - 0.5)/2

        end

      --[[  
        
        local fireDirection = (mousePos-player.position):unitvec()
    
        local result, colx, coly, sx, sy, nx, ny = player.world:castRay(player.position, fireDirection, 250, 4)
        if result == false then
            
            return
        end

        print(colx/8, coly/8)
        

        -- mirror the ray on the Y axis
        

        local collPos = jutils.vec2.new(colx, coly)

        local pass2, colx2, coly2, sx, sy, nx, ny = player.world:castRay(collPos, fireDirection, 300, 4)
        if pass2 == false then
            player.world:addEntity("laser", collPos, collPos + (fireDirection*200))
            return
        end

        player.world:addEntity("laser", collPos, jutils.vec2.new(colx2, coly2))]]
    end,
    usestep = function(self, player, dt)

    end,

    useend = function(self, player)

    end
})

baseitem:new("DRANK", {
    displayname = "DRANK",
    texture = "drank.png",
    stack = 15,
    rarity = 2,
})

baseitem:new("VAPE", {
    displayname = "JOSH'S VAPE",
    texture = "vape.png",
    stack = 1,
    rarity = 6,
    use = function(self, player)

        local fireDirection = jutils.vec2.new(input.getTransformedMouse())

    end,
    usestep = function(self, player, dt)
    end,

    useend = function(self, player)

    end
})