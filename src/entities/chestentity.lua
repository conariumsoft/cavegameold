local tileentity = require("src.entities.tileentity")
local inventory = require("src.inventory")
local jutils = require("src.jutils")

local loottables = require("src.loottables")

local chestentity = tileentity:subclass("Chest")

function chestentity:init(positions)
	tileentity.init(self, positions)

	self.inventory = inventory:new(8, 4)
	self.save = true
end

function chestentity:serialize()
	local data = {}

	data.tilepositions = self.tilepositions
	data.items = self.inventory.items
	data.type = "chest"
	print("SERIALIZING CHEST")
	return data
end

function chestentity:deserialize(data)
	print("DESERIALIZING CHEST")
	self.tilepositions = data.tilepositions
	self.inventory.items = data.items
end

function chestentity:fillLoot()
	local items = loottables:getLootForChest("UNDERGROUND_HOUSE")

	for _, data in pairs(items) do
		self.inventory:addItem(data[1], data[2])
	end
end


return chestentity