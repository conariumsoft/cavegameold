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
                    -- TODO: variable chest loot??
					entity:fillLoot()
				end
			end
		end
	end,
})

newtile("COBWEB", {
    texture = "cobweb",
    color = {1, 1, 1, 0.75},
    solid = false,
    tags = {"fakeempty"},
    hardness = 0.5,
    drop = "SILK",
    customCollision = function(entity, separation, normal)
        if separation and normal then
            if separation.x and separation.y and normal.x and normal.y then
                entity.velocity.x = jutils.math.clamp(-10, entity.velocity.x, 10)
                entity.velocity.y = jutils.math.clamp(-100, entity.velocity.y, 5)
            end
        end
    end,
})

newtile("CLOUD", {
    texture = "blank",
    color = {1, 1, 1},
    solid = false,
    tags = {"fakeempty"},
    hardness = 1,
    absorb = 0.1,
    customCollision = function(entity, separation, normal)
        if separation and normal then
            if separation.x and separation.y and normal.x and normal.y then
                entity.velocity.x = jutils.math.clamp(-20, entity.velocity.x, 20)
                entity.velocity.y = jutils.math.clamp(-100, entity.velocity.y, 20)
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