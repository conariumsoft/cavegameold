local physicalentity = require("src.entities.physicalentity")
local rendering = require("src.rendering")
local jutils = require("src.jutils")

local guiutil = require("src.guiutil")

local items = require("src.items")

local itemstack = physicalentity:subclass("Itemstack")

function itemstack:init(itemid, amount)
	physicalentity.init(self)
	
	self.boundingbox = jutils.vec2.new(4, 4)
	self.mass = 0.5
	self.id = itemid
	self.amount = amount
	self.oscillation = 0
	self.playermagnet = 0.01
	self.save = false
end

function itemstack:update(dt)
	physicalentity.update(self, dt)

	self.playermagnet = self.playermagnet + dt

	self.oscillation = self.oscillation + 3*dt

	if self.dead then return end

	for _, entity in pairs(self.world.entities) do
		
		if self ~= entity and entity:isA("Itemstack") and entity.dead == false then
			if self.position:distance(entity.position) <= 10 then
				if self.id == entity.id then
					self.amount = self.amount + entity.amount
					entity.dead = true
				end
			end
		end

		if entity:isA("Player") then
			local dist = self.position:distance(entity.position) 
			if dist <= 35 then
				if self.playermagnet > 0 then
					local attraction = 1.2
					self.velocity = self.velocity + ((entity.position-self.position):unitvec() * math.max(((35-dist)^attraction), 0.1))

					if dist <= 12 then
						local amountleft = entity.gui.inventory:addItem(self.id, self.amount)

						

						if self.amount - amountleft >= 1 then
							local data = items:getByID(self.id)


							local txt = ""

							-- TODO: make text color reflect item rarity
							if self.amount - amountleft > 1 then
								txt = tostring(self.amount-amountleft).."x"
							end
							-- TODO: make labels offset from each other.
							local label = entity.world:addEntity("floatingtext", data.displayname.. " ".. txt, {1,1,1}, guiutil.fonts.font_6)
							label:teleport(entity.position)
							label.position = label.position + jutils.vec2.new(-10, -20)
						end

						self.amount = amountleft
						if self.amount < 1 then
							self.dead = true
						end
					end
				end
			end
		end
	end
end

function itemstack:draw(dt)

	love.graphics.setColor(self.light)
	rendering.drawItem(self.id, self.position.x, self.position.y- (math.sin(self.oscillation))-1, 0.8, 0.8, 0, 4, 4)
	if self.amount > 1 then
		rendering.drawItem(self.id, self.position.x-1, self.position.y-1 - (math.sin(self.oscillation))-1, 0.8, 0.8, 0, 4, 4)
	end

	if self.amount > 10 then
		rendering.drawItem(self.id, self.position.x-2, self.position.y-2 - (math.sin(self.oscillation))-1, 0.8, 0.8, 0, 4, 4)
	end

	if self.amount > 100 then
		rendering.drawItem(self.id, self.position.x-3, self.position.y-3 - (math.sin(self.oscillation))-1, 0.8, 0.8, 0, 4, 4)
	end
end

return itemstack