local r = function(re, pr)
    recipe("alchemylab", re, pr)
end

local s = function(re, pr)
    recipe("alchemylab", {re}, {pr})
end

r({{"BOTTLE", 3}, {"CRYING_LILY", 1}}, {{"MANLET_POTION", 3}})
r({{"BOTTLE", 3}, {"MUSHROOM_PSILOCYN", 1}}, {{"GLOWING_POTION", 3}})
r({{"BOTTLE", 3}, {"BAMBOO_TILE", 1}, {"GOLD_ORE_TILE", 1}}, {{"SPEED_POTION", 3}})
r({{"BOTTLE", 3}, {"CLOUD_TILE", 2}}, {{"LOWMASS_POTION", 3}})
r({{"BOTTLE", 3}, {"MUSHROOM", 1}, {"SILVER_ORE_TILE", 3}}, {{"HEALING_POTION", 3}})
r({{"BOTTLE", 3}}, {{"INSTANT_HP_10", 3}})
r({{"BOTTLE", 3}}, {{"INSTANT_HP_50", 3}})