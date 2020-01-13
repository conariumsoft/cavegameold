local r = function(re, pr)
    recipe("workbench", re, pr)
end

local s = function(re, pr)
    recipe("workbench", {re}, {pr})
end

-- TILE -> WALL
s({"PLANK_TILE", 1}, {"PLANK_WALL", 4})
s({"STONE_TILE", 1}, {"STONE_WALL", 4})
s({"GRAY_BRICK_TILE", 1}, {"GRAY_BRICK_WALL", 4})
s({"RED_BRICK_TILE", 1}, {"RED_BRICK_WALL", 4})
s({"YELLOW_BRICK_TILE", 1}, {"YELLOW_BRICK_WALL", 4})
s({"DARK_BRICK_TILE", 1}, {"DARK_BRICK_WALL", 4})
s({"MUD_BRICK_TILE", 1}, {"MUD_BRICK_WALL", 4})

s({"GLASS_TILE", 3}, {"BOTTLE", 3})
s({"GLASS_TILE", 1}, {"GLASS_WALL", 4})

s({"IRON_INGOT", 12}, {"ANVIL", 1})
r({{"OBSIDIAN_TILE", 20}, {"BOTTLE", 3}}, {{"ALCHEMY_LAB", 1}})

s({"PLANK_TILE", 10}, {"DOOR", 1})

r({{"PLANK_TILE", 8}, {"IRON_INGOT", 2}}, {{"CHEST", 1}})

s({"STONE_TILE", 20}, {"FURNACE", 1})

s({"PLANK_TILE", 1}, {"WOOD_PANEL_WALL", 4})

s({"PLANK_TILE", 10}, {"CHAIR", 1})

r({
    {"PLANK_TILE", 15},
    {"SILK", 5}
}, {
    {"BED", 1}
})

r({
    {"PAPER", 10},
    {"SILK", 1},
}, {
    {"BOOK", 1}
})

r({
    {"PLANK_TILE", 20},
    {"BOOK", 10}
}, {
    {"BOOKSHELF", 1}
})