local r = function(re, pr)
    recipe("alchemylab", re, pr)
end

local s = function(re, pr)
    recipe("alchemylab", {re}, {pr})
end

r({{"BOTTLE", 3}, {"CRYING_LILY", 1}}, {{"MANLET_POTION", 3}})