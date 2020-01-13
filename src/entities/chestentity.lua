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

function chestentity:broken()
	for _, item in pairs(self.inventory.items) do
		local id = item[1]
		local amount = item[2]

		if id ~= 0 and amount ~= 0 then
			local e = self.world:addEntity("itemstack", id, amount)
			e:teleport(jutils.vec2.new(self.tilepositions[1][1]*8, self.tilepositions[1][2]*8))
		end
	end
	self.dead = true
end


return chestentity