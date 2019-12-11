local jutils = require("src.jutils")
local grid = require("src.grid")

newtile("CHEST_GENERATOR", {
	tileupdate = function(world, x, y)
		world:setTile(x, y, tilelist.CHEST_1_1.id)
		world:setTile(x, y+1, tilelist.CHEST_1_2.id)
		world:setTile(x+1, y, tilelist.CHEST_2_1.id)
		world:setTile(x+1, y+1, tilelist.CHEST_2_2.id)

		for _, entity in pairs(world.entities) do
			if entity:isA("Chest") then
				if entity:isAtTile(x, y) then
					entity:fillLoot()
				end
			end
		end
	end,
})

local function getGasLevel(world, x, y)
    local id = world:getTile(x, y)

    if id == tilelist.AIR.id then
        return 0
    end

    if id == tilelist.TOXIC_GAS.id then
        return world:getTileState(x, y)
    end

    return -1
end

local function setGasLevel(world, x, y, state)
    local id = world:getTile(x, y)

    if id == tilelist.TOXIC_GAS.id then
        world:setTileState(x, y, state)
    end

    if id == tilelist.AIR.id then
        world:setTile(x, y, tilelist.TOXIC_GAS.id, false)
        world:setTileState(x, y, state)
    end

end

local function gas(world, x, y)
    
end

newtile("TOXIC_GAS", {
    color = {0.2, 0.8, 0.2},
    light = {0, 0.3, 0.3},
    absorb = 0.05,
    solid = false,
    collide = true,
    onplace = function(world, x, y)
        world:rawset(x, y, "states", 1)
    end,

    customCollision = function(entity, separation, normal)

    end,
    tileupdate = gas,
    randomupdate = gas,
})

newtile("COBWEB", {
    texture = "cobweb",
    color = {1, 1, 1, 0.75},
    solid = false,
    hardness = 0.5,
    customCollision = function(entity, separation, normal)
        if separation and normal then
            
            if separation.x and separation.y and normal.x and normal.y then
                entity.velocity.x = jutils.math.clamp(-10, entity.velocity.x, 10)
                entity.velocity.y = jutils.math.clamp(-100, entity.velocity.y, 5)
                local tx, ty = grid.pixelToTileXY(entity.position.x, entity.position.y)
                local tile = entity.world:getTile(tx, ty)
                if tile == tilelist.COBWEB.id then
                    local randydandy = math.random()
                    if randydandy > 0.95 then 
                        entity.world:setTile(tx, ty, tilelist.AIR.id)
                    end 
                end
            end
        end
    end,
})


newtile("WOOB", {
	texture = "default",
	color = {0.7, 0.5, 0.2},
})


newtile("BUBBLEGUM", {
	
})

newtile("ICE", {
    texture = "glass",
})