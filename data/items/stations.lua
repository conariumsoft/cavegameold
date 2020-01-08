local tiles = require("src.tiles")
local input = require("src.input")
local grid = require("src.grid")

local function multiTilePlace(self, player)
			
    local mx, my = input.getTransformedMouse()
    local stack = player.itemHoldingStack
    local tx, ty = grid.pixelToTileXY(mx, my)

    if stack == nil then return end

    local function isempty(world, x, y)
        local tile = world:getTile(x, y)
        if tile == 0 or tiles:tileHasTag(tile, "fakeempty") then return true end
    end

    local function test(offx, offy)
        for tilename, position in pairs(self.tileset) do
            if not isempty(player.world, tx+offx+position[1], ty+offy+position[2]) then
                return false
            end
        end
        return true
    end

    local doAnyWork = false
    local xrange = (self.tilesize[1])
    local yrange = (self.tilesize[2])
    for x = 0, xrange-1 do
        for y = 0, yrange-1 do

            local realx = math.floor(xrange/2)
            local realy = math.floor(yrange/2)

            if test(x-xrange, y-yrange) then
                doAnyWork = true
                for tilename, position in pairs(self.tileset) do
                    local tileid = tiles[tilename].id

                    if tiles[tilename].validplacement then
                        local result = tiles[tilename].validplacement(player.world, (tx+x+position[1]) - xrange, (ty+y+position[2]) - yrange)

                        if result == false then
                            return 
                        end
                    end

                    player.world:setTile((tx+x+position[1]) - xrange, (ty+y+position[2]) - yrange, tileid)
                end

                stack[2] = stack[2] - 1
                return true
            end
        end
    end
end

baseitem:new("CAMPFIRE", {
    stack = 99,
    usedistance = 8,
    texture = "campfire.png",
    speed = 1/10,
    tilesize = {2, 1},
    tileset = {
        CAMPFIRE_1_1 = {1,1},
        CAMPFIRE_2_1 = {2,1},
    },
    use = multiTilePlace
})

baseitem:new("ANVIL", {
    stack = 99,
    texture = "anvil.png",
    color = {1,1,1},
    usedistance = 8,
    speed = 1/10,
    tilesize = {2, 1},
    tileset = {
        ANVIL_1_1 = {1,1},
        ANVIL_2_1 = {2,1}
    },
    use = multiTilePlace
})

baseitem:new("CHEST", {
    stack = 99,
    texture = "chest.png",
    color = {0.8, 0.6, 0.2},
    usedistance = 8,
    speed = 1/10,
    tilesize = {2, 2},
    tileset = {
        CHEST_1_1 = {1,1},
        CHEST_2_1 = {2,1},
        CHEST_1_2 = {1,2},
        CHEST_2_2 = {2,2},
    },
    use = multiTilePlace
})

baseitem:new("FURNACE", {
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {2, 2},
    texture = "furnace.png",
    tileset = {
        FURNACE_1_1 = {1,1},
        FURNACE_2_1 = {2,1},
        FURNACE_1_2 = {1,2},
        FURNACE_2_2 = {2,2},
    },
    use = multiTilePlace
})
baseitem:new("REFINERY", {
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {3, 2},
    texture = "refinery.png",
    tileset = {
        REFINERY_1_1 = {1,1},
        REFINERY_2_1 = {2,1},
        REFINERY_3_1 = {3,1},
        REFINERY_1_2 = {1,2},
        REFINERY_2_2 = {2,2},
        REFINERY_3_2 = {3,2}
    },
    use = multiTilePlace
})

baseitem:new("ALCHEMY_LAB", {
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {3, 2},
    texture = "alchemylab.png",
    tileset = {
        ALCHEMY_LAB_1_1 = {1,1},
        ALCHEMY_LAB_2_1 = {2,1},
        ALCHEMY_LAB_3_1 = {3,1},
        ALCHEMY_LAB_1_2 = {1,2},
        ALCHEMY_LAB_2_2 = {2,2},
        ALCHEMY_LAB_3_2 = {3,2}
    },
    use = multiTilePlace
})

baseitem:new("MECHANARIUM", {
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {3, 2},
    texture = "mechanarium.png",
    tileset = {
        MECHANARIUM_1_1 = {1,1},
        MECHANARIUM_2_1 = {2,1},
        MECHANARIUM_3_1 = {3,1},
        MECHANARIUM_1_2 = {1,2},
        MECHANARIUM_2_2 = {2,2},
        MECHANARIUM_3_2 = {3,2}
    },
    use = multiTilePlace
})


baseitem:new("DOOR", {
    texture = "door.png",
    color = {0.6, 0.4, 0.1},
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {1, 3},
    tileset = {
        DOOR_1_1 = {1,1},
        DOOR_1_2 = {1,2},
        DOOR_1_3 = {1,3},
    },
    use = multiTilePlace
})

baseitem:new("WORKBENCH", {
    texture = "workbench.png",
    color = {0.8, 0.6, 0.3},
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {2, 1},
    tileset = {
        WORKBENCH_1_1 = {1,1},
        WORKBENCH_2_1 = {2,1},
    },
    use = multiTilePlace,
})

baseitem:new("BOOKSHELF", {
    texture = "bookshelf.png",
    color = {1, 1, 1},
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {2, 3},
    tileset = {
        BOOKSHELF_1_1 = {1,1},
        BOOKSHELF_2_1 = {2,1},
        BOOKSHELF_1_2 = {1,2},
        BOOKSHELF_2_2 = {2,2},
        BOOKSHELF_1_3 = {1,3},
        BOOKSHELF_2_3 = {2,3},
    },
    use = multiTilePlace,
})

baseitem:new("BED", {
    texture = "bed.png",
    color = {1, 1, 1},
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {3, 1},
    tileset = {
        BED_1_1 = {1,1},
        BED_2_1 = {2,1},
        BED_3_1 = {3,1},
    },
    use = multiTilePlace,
})

baseitem:new("CHAIR", {
    texture = "chair.png",
    color = {1, 1, 1},
    stack = 99,
    usedistance = 8,
    speed = 1/10,
    tilesize = {1, 2},
    tileset = {
        CHAIR_1_1 = {1,1},
        CHAIR_1_2 = {1,2},
    },
    use = multiTilePlace,
})

baseitem:new("FOREST_PAINTING", {
    texture = "forest_painting.png",
    color = {1,1,1},
    stack = 1,
    usedistance = 8,
    speed = 1/10,
    tilesize = {1,2},
    tileset = {
        FOREST_PAINTING_1_1 = {1,1},
        FOREST_PAINTING_2_1 = {2,1},
        FOREST_PAINTING_1_2 = {1,2},
        FOREST_PAINTING_2_2 = {2,2}
    },
    use = multiTilePlace,
})