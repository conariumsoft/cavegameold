local r = function(re, pr)
    recipe("mechanarium", re, pr)
end

local s = function(re, pr)
    recipe("mechanarium", {re}, {pr})
end

r({{"ALUMINIUM_INGOT", 25}, {"COBALT_INGOT", 5}}, {{"DRILL_CHASSIS", 1}})
r({{"TITANIUM_INGOT", 25}, {"COBALT_INGOT", 5}}, {{"REINFORCED_DRILL_CHASSIS", 1}})
r({{"IRON_INGOT", 10}, {"GOLD_INGOT", 10}, {"COPPER_INGOT", 10}}, {{"STEAM_ENGINE", 1}})
r({{"VANADIUM_INGOT", 10}, {"TITANIUM_INGOT", 10}, {"COPPER_INGOT", 10}}, {{"ATOMIC_DRILL", 1}})
r({{"ENRICHED_URANIUM", 10}, {"TITANIUM_INGOT", 10}, {"COPPER_INGOT", 10}}, {{"ATOMIC_ENGINE", 1}})
r({{"STEAM_ENGINE", 1}, {"DRILL_CHASSIS", 1}}, {{"STEAM_DRILL", 1}})
r({{"ELECTRIC_ENGINE", 1}, {"DRILL_CHASSIS", 1}}, {{"POWER_DRILL", 1}})
r({{"ATOMIC_ENGINE", 1}, {"REINFORCED_DRILL_CHASSIS", 1}}, {{"ATOMIC_DRILL", 1}})