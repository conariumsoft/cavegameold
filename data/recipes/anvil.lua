local r = function(re, pr)
    recipe("anvil", re, pr)
end

local s = function(re, pr)
    recipe("anvil", {re}, {pr})
end

s({"ALUMINIUM_INGOT", 20}, {"REFINERY", 1})
r({{"TITANIUM_INGOT", 20}, {"WORKBENCH", 1}}, {{"MECHANARIUM", 1}})

--! Recipes made of iron ingot
s({"IRON_INGOT", 3}, {"BUCKET", 1})
r({{"IRON_INGOT", 12}, {"PLANK_TILE", 5}}, {{"IRON_SWORD", 1}})
r({{"IRON_INGOT", 15}, {"PLANK_TILE", 10}}, {{"IRON_PICKAXE", 1}})

s({"IRON_INGOT", 12}, {"IRON_HELMET", 1})
s({"IRON_INGOT", 20}, {"IRON_CHESTPLATE", 1})
s({"IRON_INGOT", 15}, {"IRON_LEGGINGS", 1})

--! copper recipes
s({"COPPER_INGOT", 12}, {"COPPER_HELMET", 1})
s({"COPPER_INGOT", 20}, {"COPPER_CHESTPLATE", 1})
s({"COPPER_INGOT", 15}, {"COPPER_LEGGINGS", 1})
r({{"COPPER_INGOT", 15}, {"PLANK_TILE", 10}}, {{"COPPER_PICKAXE", 1}})

--! aluminium recipes
r({{"ALUMINIUM_INGOT", 15}, {"PLANK_TILE", 10}}, {{"ALUMINIUM_PICKAXE", 1}})

--! lead recipes
s({"LEAD_INGOT", 12}, {"LEAD_HELMET", 1})
s({"LEAD_INGOT", 20}, {"LEAD_CHESTPLATE", 1})
s({"LEAD_INGOT", 15}, {"LEAD_LEGGINGS", 1})
r({{"LEAD_INGOT", 15}, {"PLANK_TILE", 10}}, {{"LEAD_PICKAXE", 1}})

r({{"TIN_INGOT", 15}, {"PLANK_TILE", 10}}, {{"TIN_PICKAXE", 1}})


--? i might move palladium and cobalt recipes to the refinery...
--! palladium recipes

s({"PALLADIUM_INGOT", 10}, {"PALLADIUM_HELMET", 1})
s({"PALLADIUM_INGOT", 15}, {"PALLADIUM_CHESTPLATE", 1})
s({"PALLADIUM_INGOT", 12}, {"PALLADIUM_LEGGINGS", 1})

r({{"PALLADIUM_INGOT", 15}, {"PLANK_TILE", 10}}, {{"PALLADIUM_PICKAXE", 1}})

r({{"PALLADIUM_INGOT", 18}, {"tag:plank", 15}}, {{"PALLADIUM_SWORD", 1}})


--! cobalt recipes
s({"COBALT_INGOT", 10}, {"COBALT_HELMET", 1})
s({"COBALT_INGOT", 15}, {"COBALT_CHESTPLATE", 1})
s({"COBALT_INGOT", 12}, {"COBALT_LEGGINGS", 1})

r({{"COBALT_INGOT", 15}, {"PLANK_TILE", 10}}, {{"COBALT_PICKAXE", 1}})

r({{"COBALT_INGOT", 18}, {"tag:plank", 15}}, {{"COBALT_SWORD", 1}})



s({"IRON_INGOT", 1}, {"BULLET", 25})
s({"SILVER_INGOT", 1}, {"SILVER_BULLET", 25})
s({"PLANK_TILE", 1}, {"ARROW", 10})