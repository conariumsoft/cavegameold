--- Loot table definitions, items are selected from a pool to fill chests.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local items = require("src.items")

local mod = {}

local lootvalues = {
	["UNDERGROUND_HOUSE"] = {
		rolls = 24,
		items = {
			{item = items.IRON_INGOT.id, chance = 30, min = 1, max = 3, once = false},
			{item = items.COPPER_INGOT.id, chance = 30, min = 1,	max = 3,	once = false},
			{item = items.BOMB.id, chance = 25, min = 1,	max = 6,	once = false},
			{item = items.MUSHROOM.id,	chance = 12, min = 1,	max = 3,	once = false},
			{item = items.MUSHROOM_POISONOUS.id,	chance = 12, min = 1,	max = 3,	once = false},
			{item = items.MUSHROOM_PSILOCYN.id,	chance = 12, min = 1,	max = 3,	once = false},
			{item = items.LOWMASS_POTION.id,	chance = 25, min = 1,	max = 3,	once = false},
			{item = items.MUSHROOM.id, chance = 25, min = 1,	max = 3, once = false},
			{item = items.SPEED_POTION.id, chance = 25, min = 1, max = 3, once = false},
			{item = items.MANLET_POTION.id, chance = 10, min = 1, max = 1, once = false},
			{item = items.FLINTLOCK.id, chance = 1, min = 1, max = 1, once = true}
		},
	}
}

function mod:getLootForChest(lootid)
	local getting = {}

	local lootTable = lootvalues[lootid]

	local ref = {}

	for i = 1, lootTable.rolls do
		local itemselected = lootTable.items[math.random(1, #lootTable.items)]
		local chance = math.random(1, 100)
		if ref[itemselected.item] ~= true then
			if chance < itemselected.chance then
				local amount = math.random(itemselected.min, itemselected.max)

				table.insert(getting, {itemselected.item, amount})

				if itemselected.once == true then
					ref[itemselected.item] = true
				end
			end
		end
	end

	return getting
end

return mod