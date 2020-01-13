--- Inventory base class.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local items = require("src.items")
local jutils = require("src.jutils")

local inventory = jutils.object:subclass("Inventory")

-- TODO: Add item tag whitelists

--- Create a new inventory instance with <code>width</code> * <code>height</code> item slots.
-- @name inventory:new
-- @param width 
-- @param height
-- @return Inventory
function inventory:init(width, height)
	self.width = width
	self.height = height

	self.items = {}

	for index = 1, self.width * self.height do
		self.items[index] = {0, 0}
	end
end
---
function inventory:getSlotIndex(x, y)
	local index = ((y - 1) * self.width) + x
	return index
end
---
function inventory:getSlotXY(index)
	local x = (index - 1) % (self.width) + 1
	local y = math.floor((index - 1) / self.width) + 1

	return x, y
end
---
function inventory:getSlot(index)
	return self.items[index][1], self.items[index][2]
end

---
function inventory:setSlot(index, itemid, amount)
	self.items[index] = {itemid, amount}
end

---
function inventory:addItem(item, amount)
	local amountleft = amount
	for _, data in pairs(self.items) do
		local itemdata = items:getByID(item)

		-- itemstack is the same or is empty
		if amountleft < 1 then return 0 end
		if data[1] == item or data[1] == 0 then
			
			data[1] = item

			-- stack isn't full
			while (itemdata.stack > data[2]) and amountleft > 0 do
				data[2] = data[2] + 1
				
				amountleft = amountleft - 1
			end
		end
	end
	return amountleft
end

---
function inventory:hasItem(item, amount)
	local amounthas = 0

	for index, data in pairs(self.items) do
		-- itemstack is the same or is empty
		if data[1] == item then
			amounthas = amounthas + data[2]
		end
	end

	if amounthas >= amount then
		return true, amounthas
	end
	return false
end

-- TODO: this still is buggy
---
function inventory:removeItem(item, amount)
	local amountleft = amount
	for _, data in pairs(self.items) do
		local itemdata = items:getByID(item)

		-- itemstack is the same or is empty
		if amountleft < 1 then return 0 end
		if data[1] == item or data[1] == 0 then
			data[1] = item

			-- stack isn't full
			while (data[2] > 0) and amountleft > 0 do
				data[2] = data[2] - 1
				amountleft = amountleft - 1
			end
		end
	end
	return amountleft
end

---
function inventory:getContents()
	return self.items
end

---
function inventory:update(dt)
	for idx, stack in pairs(self.items) do
		if stack[2] < 1 then stack[1] = 0 end
		if stack[1] == 0 then stack[2] = 0 end
	end
end

return inventory