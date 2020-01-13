local r = function(re, pr)
    recipe("anvil", re, pr)
end

local s = function(re, pr)
    recipe("anvil", {re}, {pr})
end

s({"ALUMINIUM_INGOT", 20}, {"REFINERY", 1})
r({{"TITANIUM_INGOT", 20}, {"WORKBENCH", 1}}, {{"MECHANARIUM", 1}})
s({"IRON_INGOT", 3}, {"BUCKET", 1})

r({{"IRON_INGOT", 12}, {"PLANK_TILE", 5}}, {{"IRON_SWORD", 1}})

r({{"IRON_INGOT", 15}, {"PLANK_TILE", 10}}, {{"IRON_PICKAXE", 1}})
r({{"COPPER_INGOT", 15}, {"PLANK_TILE", 10}}, {{"COPPER_PICKAXE", 1}})
r({{"LEAD_INGOT", 15}, {"PLANK_TILE", 10}}, {{"LEAD_PICKAXE", 1}})
r({{"TIN_INGOT", 15}, {"PLANK_TILE", 10}}, {{"TIN_PICKAXE", 1}})
r({{"PALLADIUM_INGOT", 15}, {"PLANK_TILE", 10}}, {{"PALLADIUM_PICKAXE", 1}})
r({{"ALUMINIUM_INGOT", 15}, {"PLANK_TILE", 10}}, {{"ALUMINIUM_PICKAXE", 1}})


s({"IRON_INGOT", 1}, {"BULLET", 25})
s({"SILVER_INGOT", 1}, {"SILVER_BULLET", 25})
s({"PLANK_TILE", 1}, {"ARROW", 10})