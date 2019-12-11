-- liquid tiles
local jutils = require("src.jutils")

local air_id
local water_id
local lava_id

local function getWaterLevel(world, x, y)
    local id = world:getTile(x, y)
    if id == air_id then return 0 end
    if id == water_id then return world:getTileState(x, y) end
    if tilemanager:tileHasTag(id, "fakeempty") then return 0 end
    return -1
end

local function setWaterLevel(world, x, y, state)
    local id = world:getTile(x, y)

    if id == water_id then
        world:setTileState(x, y, state)
        return
    end

    if id == air_id or tilemanager:tileHasTag(id, "fakeempty") then
        world:setTile(x, y, water_id, false)
        world:setTileState(x, y, state)
        return
    end
end

local waterLevels = 8

newtile("WATER",{
    color = {0, 0, 0.5},
    solid = false,
    collide = true,
    absorb = 0.05,
    tags = {"fakeempty"},
    onplace = function(world, x, y)
        world:rawset(x, y, "states", waterLevels)
    end,
    customCollision = function(entity, separation, normal)
        if separation and normal then
            
            if separation.x and separation.y and normal.x and normal.y then
                entity.velocity.x = jutils.math.clamp(-30, entity.velocity.x, 30)
                entity.velocity.y = jutils.math.clamp(-200, entity.velocity.y, 40)
                
            end
        end
    end,
    tileupdate = function(world, x, y)
        
        local waterMax = 8

        local this = getWaterLevel(world, x, y)
        if this < 1 then
            world:setTile(x, y, air_id, false)
            return
        end
        
        -- try to flow downward
        local below = getWaterLevel(world, x, y+1)
        local function check(val)
            if val ~= -1 and val < waterMax then return true end
        end

        if check(below) and this > 0 then

            local most = waterMax-below

            local taken = math.min(most, this)
            this = this-taken
            below = below+taken
            setWaterLevel(world, x, y, this)
            setWaterLevel(world, x, y+1, below)
            return
        end

        -- try to flow outwards once you're on the ground?
        local left = getWaterLevel(world, x-1, y)
        if check(left) and this > 0 and this~=left then
            if this > left+1 then
                this = this-1
                left = left+1
            elseif this-left == 1 then
                local rand = math.random()
                if rand > 0.5 then
                    this = this
                    left = this
                else
                    this = left
                    left = left
                end
            end
            setWaterLevel(world, x, y, this)
            setWaterLevel(world, x-1, y, left)
        end

        local right = getWaterLevel(world, x+1, y)
        if check(right) and this > 0 and this ~= right then
            if this > right+1 then
                this = this-1
                right = right+1
            elseif this-right == 1 then
                local rand = math.random()
                if rand > 0.5 then
                    this = this
                    right = this
                else
                    this = right
                    right = right
                end
            end
            setWaterLevel(world, x, y, this)
            setWaterLevel(world, x+1, y, right)
        end
    end,
})

local function getLavaLevel(world, x, y)
    local id = world:getTile(x, y)

    if id == air_id then
        return 0
    end

    if id == lava_id then
        return world:getTileState(x, y)
    end

    if tilemanager:tileHasTag(id, "fakeempty") then
        return 0
    end

    return -1
end

local function setLavaLevel(world, x, y, state)
    local id = world:getTile(x, y)

    if id == lava_id then
        world:setTileState(x, y, state)
        return
    end

    if id == air_id or tilemanager:tileHasTag(id, "fakeempty") then
        world:setTile(x, y, lava_id, false)
        world:setTileState(x, y, state)
        return
    end

end

newtile("LAVA", {
    color = {0.9, 0, 0},
    light = {1.75, 1, 0.75},
    absorb = 0,
    solid = false,
    collide = true,
    tags = {"fakeempty"},
    onplace = function(world, x, y)
        world:rawset(x, y, "states", waterLevels)
    end,
    customCollision = function(entity, separation, normal)

        if separation and separation.x and separation.y and normal and normal.x and normal.y then
            entity.velocity.x = jutils.math.clamp(-10, entity.velocity.x, 10)
            entity.velocity.y = jutils.math.clamp(-200, entity.velocity.y, 10)
            entity.touchinglava = true

            if entity:isA("Itemstack") then
                entity.dead = true
            end
        end
    end,
    tileupdate = function(world, x, y)
        local lavaMax = 8

        local this = getLavaLevel(world, x, y)
        if this < 1 then
            world:setTile(x, y, air_id, false)
            return
        end

        for dx = -1, 1 do
            if world:getTile(x+dx, y) == water_id then
                if this == 8 then
                    world:setTile(x+dx, y, air_id, false)
                    world:setTile(x, y, tilelist.OBSIDIAN.id, false)
                else
                    world:setTile(x+dx, y, air_id, false)
                    world:setTile(x, y, tilelist.STONE.id, false)
                end
                return
            end
        end
        for dy = -1, 1 do
            if world:getTile(x, y+dy) == water_id then
                if this == 8 then
                    world:setTile(x, y+dy, air_id, false)
                    world:setTile(x, y, tilelist.OBSIDIAN.id, false)
                else
                    world:setTile(x, y+dy, air_id, false)
                    world:setTile(x, y, tilelist.STONE.id, false)
                end
                return
            end
        end
        
        -- try to flow downward
        local below = getLavaLevel(world, x, y+1)
        local function check(val)
            if val ~= -1 and val < lavaMax then return true end
        end

        if check(below) and this > 0 then
            this = this-1
            below = below+1
            setLavaLevel(world, x, y, this)
            setLavaLevel(world, x, y+1, below)
            return
        end

        -- try to flow outwards once you're on the ground?
        local left = getLavaLevel(world, x-1, y)
        if check(left) and this > 0 and this~=left then
            if this > left+1 then
                this = this-1
                left = left+1
            elseif this-left == 1 then
                local rand = math.random()
                if rand > 0.5 then
                    this = this
                    left = this
                else
                    this = left
                    left = left
                end
            end
            setLavaLevel(world, x, y, this)
            setLavaLevel(world, x-1, y, left)
        end

        local right = getLavaLevel(world, x+1, y)
        if check(right) and this > 0 and this ~= right then
            if this > right+1 then
                this = this-1
                right = right+1
            elseif this-right == 1 then
                local rand = math.random()
                if rand > 0.5 then
                    this = this
                    right = this
                else
                    this = right
                    right = right
                end
            end
            setLavaLevel(world, x, y, this)
            setLavaLevel(world, x+1, y, right)
        end
    end
})

air_id = tilelist.AIR.id
water_id = tilelist.WATER.id
lava_id = tilelist.LAVA.id