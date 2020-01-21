local r = function(re, pr)
    recipe("refinery", re, pr)
end

local s = function(re, pr)
    recipe("refinery", {re}, {pr})
end

s({"PALLADIUM_ORE_TILE", 3}, {"PALLADIUM_INGOT", 1})
s({"CHROMIUM_ORE_TILE", 3}, {"CHROMIUM_INGOT", 1})
s({"NICKEL_ORE_TILE", 3}, {"NICKEL_INGOT", 1})
s({"VANADIUM_ORE_TILE", 3}, {"VANADIUM_INGOT", 1})
s({"COBALT_ORE_TILE", 3}, {"COBALT_INGOT", 1})
s({"TITANIUM_ORE_TILE", 3}, {"TITANIUM_INGOT", 1})
s({"URANIUM_ORE_TILE", 3}, {"ENRICHED_URANIUM", 1})