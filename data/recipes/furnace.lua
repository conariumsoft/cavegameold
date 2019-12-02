local r = function(re, pr)
    recipe("furnace", re, pr)
end

local s = function(re, pr)
    recipe("furnace", {re}, {pr})
end

s({"STONE_TILE", 4}, {"GRAY_BRICK_TILE", 4})
s({"SOFT_CLAY_TILE", 4}, {"RED_BRICK_TILE", 4})
s({"SANDSTONE_TILE", 4}, {"YELLOW_BRICK_TILE", 4})
s({"MUD_TILE", 4}, {"MUD_BRICK_TILE", 4})

s({"SAND_TILE", 4}, {"GLASS_TILE", 4})


s({"IRON_ORE_TILE", 2}, {"IRON_INGOT", 1})
s({"COPPER_ORE_TILE", 2}, {"COPPER_INGOT", 1})
s({"LEAD_ORE_TILE", 3}, {"LEAD_INGOT", 1})
s({"GOLD_ORE_TILE", 3}, {"GOLD_INGOT", 1})
s({"SILVER_ORE_TILE", 3}, {"SILVER_INGOT", 1})
s({"TIN_ORE_TILE", 3}, {"TIN_INGOT", 1})
