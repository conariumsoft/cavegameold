--- Player's user interface while playing in a world.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

-- TODO: this whole script is fucky, fix it

local uiscale = 1

local jutils   = require("src.jutils")
local jui      = require("src.jui")
local grid     = require("src.grid")
local items    = require("src.items")
local recipes = require("src.recipes")
local rendering = require("src.rendering")
local tiles = require("src.tiles")
local inventory = require("src.inventory")
local guiutil = require("src.guiutil")

-- why the fuck is this an object?
-- this is actually a question i continually ask.
-- TODO: seriously sit down and figure out a monolithic playergui
--! not now though, focus on finishing up the game
local system = jutils.object:subclass("PlayerGui")

-- ! ghetto retard hack because im lazy
local the_player = nil

local menu = jui.scene:new({}, {
    bg = jui.rectangle:new({
		scaleSize = jutils.vec2.new(1, 1),
		pixelSize = jutils.vec2.new(0, 0),
		scalePosition = jutils.vec2.new(0, 0),
		pixelPosition = jutils.vec2.new(0, 0),
		borderEnabled = false,
		backgroundColor = {0, 0, 0, 0.5}
	}, {
		exitbutton = jui.nineslice:new({
			scaleSize = jutils.vec2.new(0, 0),
			pixelSize = jutils.vec2.new(150, 25),
			scalePosition = jutils.vec2.new(1, 1),
			pixelPosition = jutils.vec2.new(-155, -30),
			color = {1, 1, 1},
			image = love.graphics.newImage("assets/ui/niner.png"),
			imageScale  = 2,
			sourceWidth = 8,
			sourceHeight = 8,
			cornerWidth = 3,
			cornerHeight = 3,

		}, {
			bg = jui.text:new({
				text = "Save and Exit",
				textColor = jutils.color.fromHex("#FFFFFF"),
				font = guiutil.fonts.font_14,
				textXAlign = "center",
				textYAlign = "center"
			}),
			klik = jui.mouseListener:new({
				mouseButtonUp = function()
					the_player.world.tryingToEnd = true
				end,
			})
		})
	})
})

-- why the fuck is it instanced?
-- should just make it a monolith module
function system:init(player)
	self.open = false

	self.player = player
	self.cursor = inventory:new(1, 1)
	self.openContainer = nil
	self.inventory = inventory:new(10, 4)
	self.equipment = inventory:new(2, 3)
	self.hotbarSelection = 1
	self.slotsize = 32
	self.recipeLookingAt = nil
	self.slotPointingAt = -1
	self.updateNearbyRecipeTimer = 0
	self.craftcounting = false
	self.craftspeedup = 0
	self.slotpadding = 4
	self.recipe_scroll = 0
	self.fullslotsize = self.slotsize+self.slotpadding

	the_player = player
end

function system:scroll(diff)
	if self.open == true then
		self.recipe_scroll = self.recipe_scroll - diff

		if self.recipe_scroll < 0 then self.recipe_scroll = 0 end
		return true
	end
	return false
end

local function itemHasTag(itemid, tag)
	local data = items:getByID(itemid)
	if data.tags and jutils.table.contains(data.tags, tag) then
		return true
	end
end

local function haveItemWithTag(inv, tag, amount)
	amount = amount or 1
	for _, invitem in pairs(inv.items) do
		local id = invitem[1]
		if id ~= 0 then
			if itemHasTag(id, tag) then
				if invitem[2] >= amount then
					return true
				end
			end
		end
	end
	return false
end

local function getItemWithTag(inv, tag)
	for index, invitem in pairs(inv.items) do
		local id = invitem[1]
		if id ~= 0 then
			local data = items:getByID(id)
			if itemHasTag(id, tag) then
				return data, index
			end
		end
	end
end

function system:getScreenSize()
	return love.graphics.getWidth() / uiscale, love.graphics.getHeight() / uiscale
end

function system:getMouse()
	return love.mouse.getX() / uiscale, love.mouse.getY() / uiscale
end

function system:pass()

end

function system:getEquippedItem()
	if self.cursor.items[1][1] ~= 0 and self.cursor.items[1][2] > 0 then
		return self.cursor.items[1]
		
	elseif self.inventory.items[self.hotbarSelection][1] ~= 0 then
		return self.inventory.items[self.hotbarSelection]
	end
	return nil
end

function system:recipe_click(button)
	for _, reactant in pairs(self.recipeLookingAt.reactants) do
		if reactant[1]:sub(1, 4) == "tag:" then
			--print(reactantItemID:sub(1, 4), reactantItemID:sub(5))
			local reactantTag = reactant[1]:sub(5)
			local data = getItemWithTag(self.inventory, reactantTag)
			self.inventory:removeItem(data.id, reactant[2])
		else
			self.inventory:removeItem(items[reactant[1]].id, reactant[2])
		end
	end

	for _, product in pairs(self.recipeLookingAt.products) do
		self.inventory:addItem(items[product[1]].id, product[2])
	end
	if button == 2 then
		self.craftcounting = true
	end
end

function system:clicked(button, istouch, presses)
	local menuhandled = false

	if self.recipeLookingAt ~= nil then
		self:recipe_click(button)
		return true
	end

	if self.slotPointingAt ~= -1 then
		local inv = self.inventory
		local offset = 0

		if self.slotPointingAt > 80 then
			inv = self.equipment
			offset = 80
		elseif self.slotPointingAt > 40 then
			inv = self.openContainer
			offset = 40
		end

		
		local slot = inv.items[self.slotPointingAt-offset]
		local sid, samount = slot[1], slot[2]

		local mid, mamount = self.cursor.items[1][1], self.cursor.items[1][2]

		if button == 1 then
			if love.keyboard.isDown("lshift") and self.openContainer ~= nil then
				if inv == self.inventory then
					local amtleft = self.openContainer:addItem(sid, samount)
					inv.items[self.slotPointingAt-offset][2] = amtleft
				end

				if inv == self.openContainer then
					local amtleft = self.inventory:addItem(sid, samount)
					inv.items[self.slotPointingAt-offset][2] = amtleft
				end
			else

				local function swap()
					self.cursor.items[1] = {sid, samount}
					inv.items[self.slotPointingAt-offset] = {mid, mamount}
				end

				if mid == sid then
					-- TODO: max checking
					slot[2] = slot[2] + mamount
					self.cursor.items[1] = {0, 0}
				else
					if inv == self.equipment then
						-- confirm the item in the cursor can go

						local success = false
						
						if mid == 0 then
							self.cursor.items[1] = {sid, samount}
							inv.items[self.slotPointingAt-offset] = {mid, mamount}
							success = true
						else
							local data = items:getByID(mid)

							if self.slotPointingAt-offset == 1 then
								if data.helmet then swap() success = true end
								
							elseif self.slotPointingAt-offset == 3 then
								if data.chestplate then swap() success = true end
								
							elseif self.slotPointingAt-offset == 5 then
								if data.leggings then swap() success = true end
							else
								if data.accessory then swap() success = true end
							end
						end

						if success == true then
							if sid ~= 0 then
								local old_item_data = items:getByID(sid)
	
								if old_item_data.onUnequip then
									old_item_data:onUnequip(self.player)
								end
							end
							
							if mid ~= 0 then
								local new_item_data = items:getByID(mid)

								if new_item_data.onEquip then
									new_item_data:onEquip(self.player)
								end
							end
						end
					else
						swap()
					end
				end
			end
			menuhandled = true
		elseif button == 2 then
				
			if sid > 0 then
				if mid == sid or mid == 0 then
					
					self.cursor.items[1][1] = sid
					self.cursor.items[1][2] = self.cursor.items[1][2] + 1
					slot[2] = slot[2] - 1
					menuhandled = true
				end
			end
		end
	end
	
	return menuhandled
end

local validRecipeList = {}

local crafttick = 0

local craftingStationSearchRange = 6
-- you ever heard of a game called phantom forces?
function system:updateRecipeList()
	validRecipeList = {}

	local numRecipes = 0
	for station, recipe in pairs(recipes) do

		local nearby = false
		local playerworld = self.player.world
		local playerTileX, playerTileY = grid.pixelToTileXY(self.player.position.x, self.player.position.y)

		if station == "none" then
			nearby = true
		else
			for x = -craftingStationSearchRange, craftingStationSearchRange do
				for y = -craftingStationSearchRange, craftingStationSearchRange do
					local tile = playerworld:getTile(playerTileX+x, playerTileY+y)

					if tiles:tileHasTag(tile, station) then
						nearby = true
					end
				end
			end

		end
		if nearby == true then
			validRecipeList[station] = true
		end
		
	end
	--if self.recipe_scroll > numRecipes then self.recipe_scroll = numRecipes end
end

function system:update(dt)
	menu:update(dt)
	uiscale = love.graphics.getWidth()/1000
	self.inventory:update(dt)
	self.cursor:update(dt)
	if self.openContainer then
		self.openContainer:update(dt)
	end
	self.equipment:update(dt)
	if self.open then
		self.updateNearbyRecipeTimer = self.updateNearbyRecipeTimer + dt

		if self.updateNearbyRecipeTimer > (1/5) then
			self.updateNearbyRecipeTimer = 0
			
			self:updateRecipeList()
		end
	else
		self.openContainer = nil
	end

	if love.mouse.isDown(2) then
		if self.recipeLookingAt ~= nil and self.craftcounting == true then

			crafttick = crafttick + dt

			if self.craftspeedup > (1/60) then
				self.craftspeedup = self.craftspeedup - (dt/2)
			end

			if crafttick > (self.craftspeedup) then
				crafttick = 0
				for _, reactant in pairs(self.recipeLookingAt.reactants) do
					if reactant[1]:sub(1, 4) == "tag:" then
						--print(reactantItemID:sub(1, 4), reactantItemID:sub(5))
						local reactantTag = reactant[1]:sub(5)
						local data = getItemWithTag(self.inventory, reactantTag)
						self.inventory:removeItem(data.id, reactant[2])
					else
						self.inventory:removeItem(items[reactant[1]].id, reactant[2])
					end
				end

				for _, product in pairs(self.recipeLookingAt.products) do
					self.inventory:addItem(items[product[1]].id, product[2])
				end
			end

		end
	else
		self.craftspeedup = 0.5
		self.craftcounting = false
	end
end

local function drawItem(x, y, size, id, amount)
	if id > 0 then

		rendering.drawItem(id, x+1, y+1, size/9, size/9)

		if amount > 1 then
			love.graphics.setColor(0, 0, 0)
			love.graphics.setFont(guiutil.fonts.font_14)
			local f = love.graphics.getFont()
			local h = f:getHeight()

			love.graphics.printf(amount, x, y+size - h, size, "right")
		end
	end
end

local max_shown_recipes = 10

function system:drawRecipes()
	love.graphics.setColor(1,1,1)
	love.graphics.print("Crafting", 5, 5)
	local slotY = 0
	
	local startx = 32
	local starty = 24
	local mx, my = self:getMouse()
	local idx = 0
	local counter = 0

	local show_top_arrow = (self.recipe_scroll == 0) and true or false
	local show_bottom_arrow = true

	for station, list in pairs(recipes) do
		for _, recipe in pairs(list) do
			-- check if player has the nessecary items for the recipe
			local plrIsNearStation = validRecipeList[station]
			local plrHasReactants = true
			for _, reactant in pairs(recipe.reactants) do
				local reactantItemID = reactant[1]
				local reactantAmount = reactant[2]

				if reactantItemID:sub(1, 4) == "tag:" then
					--print(reactantItemID:sub(1, 4), reactantItemID:sub(5))
					local reactantTag = reactantItemID:sub(5)
					if haveItemWithTag(self.inventory, reactantTag) == false then
						plrHasReactants = false
					end
				else
					local itemdata = items[reactantItemID]
					-- TODO: improve details for unit test of recipe
					assert(itemdata ~= nil, "unit test fail: item "..reactant[1].." doesn't exist, fix your recipe list!")

					if self.inventory:hasItem(itemdata.id, reactantAmount) == false then
						plrHasReactants = false
					end
				end
			end

			--* this would be a good use case for immediate mode GUI
			if plrIsNearStation and plrHasReactants then
		
				if self.recipe_scroll > idx then
					idx = idx + 1
				else
					counter = counter + 1
	
					if counter <= max_shown_recipes then
								
						-- draw box
						local num = #recipe.reactants + #recipe.products + 1
						local boxX = startx
						local boxY = starty+(slotY*self.slotsize) + (slotY*2)

						local boxW = (num*self.slotsize)
						local boxH = self.slotsize
						local size = self.slotsize

						love.graphics.setColor(1,1,1, 0.5)
						if mx > boxX and mx < boxX+boxW and my > boxY and my < boxY+boxH then
							love.graphics.setColor(1,1,1)
							self.recipeLookingAt = recipe

							local str = ""
							for _, product in pairs(recipe.products) do
								local iteminfo = items[product[1]]
								local quantity = product[2]


								str = str .. iteminfo.displayname .. " ("..tostring(quantity).."x)\n"
							end
							local str2 = "Need:\n"
							for _, reactant in pairs(recipe.reactants) do
								
								local quantity = reactant[2]
								if reactant[1]:sub(1, 4) == "tag:" then
									str2 = str2 .. "any "..reactant[1]:sub(5).. " ("..tostring(quantity).."x)\n"
								else
									local iteminfo = items[reactant[1]]

									str2 = str2 .. iteminfo.displayname.. " ("..tostring(quantity).."x)\n"
								end
							end

							love.graphics.setFont(guiutil.fonts.font_16)
							love.graphics.print(str, boxX+boxW+10, boxY)

							love.graphics.setFont(guiutil.fonts.font_12)
							love.graphics.print(str2, boxX+boxW+10, boxY+(boxH/2))

						end

						love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
						
						local slotX = 0
						for _, reactant in pairs(recipe.reactants) do
							local iteminfo
							if reactant[1]:sub(1, 4) == "tag:" then
								local reactantTag = reactant[1]:sub(5)
								local data, slot = getItemWithTag(self.inventory, reactantTag)
								iteminfo = data
							else
								iteminfo = items[reactant[1]]
							end
							drawItem( startx+(slotX*size), boxY, self.slotsize, iteminfo.id, reactant[2])

							slotX = slotX + 1
						end

						love.graphics.setColor(0,0,0)
						love.graphics.printf("->", startx+(slotX*size), boxY+(boxH/4), size, "center")
						slotX = slotX + 1
						for _, product in pairs(recipe.products) do
							local iteminfo = items[product[1]]
							drawItem(startx+(slotX*size), boxY, self.slotsize, iteminfo.id, product[2])

							slotX = slotX + 1
						end

						slotY = slotY + 1
					end
				end
			end
		end
	end

	love.graphics.setColor(1, 1, 1)

	love.graphics.setFont(guiutil.fonts.font_14)

	if show_top_arrow then
		love.graphics.print("\\/", 4, 40)
	elseif show_bottom_arrow then
		love.graphics.print("/\\", 4, 40)
		
	end
end

-- item rarity colors
local rarityColors = {
	[-1] = {0, 0, 0},
	[0] = {0.6, 0.6, 0.6},
	[1] = {1,1,1},
	[2] = {0.5, 1, 0.5},
	[3] = {0.5, 0.5, 1},
	[4] = {1, 0.5, 0.5},
	[5] = {1, 0.5, 1},
	[6] = {1, 1, 0.5},
}

function system:drawItemData(x, y, gridx, gridy, slotsize, itemid, amount, highlighted, grown)

	local finalX = x + (gridx*slotsize) + (self.slotpadding*gridx)
	local finalY = y + (gridy*slotsize) + (self.slotpadding*gridy)

	if highlighted then
		love.graphics.setColor(1,1,1)
	else
		love.graphics.setColor(1,1,1, 0.5)
	end
	
	local rx, ry = 0, 0
	local padding = 1
	if highlighted then
		rx, ry = 2, 2
		padding = 3
	end
	
	local effectiveX = finalX-padding
	local effectiveY = finalY-padding
	local effectiveSize = slotsize+(padding*2)

	local mx, my = self:getMouse()
	local mouseon = false
	if mx > effectiveX and mx < effectiveX+effectiveSize then
		if my > effectiveY and my < effectiveY+effectiveSize then
			mouseon = true
			padding = 2
			rx = 2
			ry = 2
			love.graphics.setColor(1,1,1)
		end
	end

	love.graphics.rectangle("fill", effectiveX, effectiveY, effectiveSize, effectiveSize, rx, ry)
	drawItem(finalX, finalY, slotsize, itemid, amount)

	return mouseon
end

love.graphics.setFont(guiutil.fonts.font_16)
local text = love.graphics.newText(love.graphics.getFont())

local ITEM_DEBUG_INFO = true

function system:drawFullInventory()
	
	local w, h = self:getScreenSize()
	for index = 1, 40 do
		local id, amount = self.inventory:getSlot(index)
		local slotx, sloty = self.inventory:getSlotXY(index)

		local res = self:drawItemData(4, h-(self.fullslotsize*5) -4, slotx-1, sloty, self.slotsize, id, amount)
		if res then
			self.slotPointingAt = index
		end
	end

	if self.openContainer then
		for index = 1, #self.openContainer.items do
			local id, amount = self.openContainer:getSlot(index)
			local slotx, sloty = self.openContainer:getSlotXY(index)

			local res = self:drawItemData(w-(self.fullslotsize*(self.openContainer.width)), h-(self.fullslotsize*(self.openContainer.height+1)) - 4, slotx-1, sloty, self.slotsize, id, amount)
			if res then
				self.slotPointingAt = 40+index
			end
		end
	else
		for index = 1, 6 do
			local id, amount = self.equipment:getSlot(index)
			local slotx, sloty = self.equipment:getSlotXY(index)
	
			local res = self:drawItemData(w-(self.fullslotsize*(self.equipment.width)), h-(self.fullslotsize*5) -4, slotx-1, sloty, self.slotsize, id, amount)
			if res then
				self.slotPointingAt = 80+index
			end
		end


		-- display player's defense

		local def = self.player.defense
		love.graphics.setColor(1,1,1)
		love.graphics.print(def, w-(self.fullslotsize*(self.equipment.width)) - 30, h-(self.fullslotsize*5))
	end

	-- draw item pointing at data
	if self.slotPointingAt ~= -1 then
		local slot = self.inventory.items[1]
		if self.slotPointingAt > 80 then
			slot = self.equipment.items[self.slotPointingAt-80]
		elseif self.slotPointingAt > 40 then
			slot = self.openContainer.items[self.slotPointingAt-40]
		else
			slot = self.inventory.items[self.slotPointingAt]
		end

		local id = slot[1]
		
		if id > 0 and slot[2] > 0 then
			text:clear()
			local data = items:getByID(id)
			
			local f = love.graphics.getFont()
			local color = rarityColors[data.rarity]
			text:add({color, data.displayname}, 0, 0, 0, 1.1, 1.1)
			
			if data.tooltip then
				local function substitute(input, valuename, func)
					local sub = ""
					
						
					if data[valuename] then
						sub = data[valuename]
						if func then
							sub = func(data[valuename])
						end

						input = input:gsub("{"..valuename.."}", sub)
					end
					return input
				end

				local tooltip = data.tooltip

				tooltip = substitute(tooltip, "usedistance")
				tooltip = substitute(tooltip, "strength")
				tooltip = substitute(tooltip, "speed", function(n)return 1/n end)
				tooltip = substitute(tooltip, "range", function(n)return n/8 end)
				tooltip = substitute(tooltip, "knockback")
				tooltip = substitute(tooltip, "damage")

				text:add({{0.7,0.7,0.7},tooltip}, 0, f:getHeight()+8)
			end

			if ITEM_DEBUG_INFO then

				text:add({{0.5, 0.5, 0.5}, "id: "..data.id.."\namount: "..slot[2].."\nmax: "..data.stack }, 0, text:getHeight()+f:getHeight()+8)
			end
			love.graphics.setColor(1,1,1)
			love.graphics.draw(text, 10 + 10*self.fullslotsize, h-(4*self.fullslotsize))

		end
	end
end

function system:drawItemInCursor()
	local mx, my = self:getMouse()

	local id, amount = self.cursor:getSlot(1)

	if id > 0 and amount > 0 then
		love.graphics.setFont(guiutil.fonts.font_16)
		drawItem(mx-(self.slotsize/2), my-(self.slotsize/2), self.slotsize, id, amount)
	end
end

function system:drawHotbar()
	local w, h = self:getScreenSize()
	for index = 1, 10 do
		local id, amount = self.inventory:getSlot(index)
		self:drawItemData(4, h-self.fullslotsize-4, index-1, 0, self.slotsize, id, amount, (index==self.hotbarSelection))
		
		-- hotbar tooltip
		if index == self.hotbarSelection then
			if id > 0 then
				local info = items:getByID(id)

				love.graphics.setColor(rarityColors[info.rarity])
				love.graphics.print(info.displayname, 4, h-self.fullslotsize-20)
			end
		end
	end
end

local DEBUG_INFO = true

-- potion effects, debuffs, etc
function system:drawStatusEffects()
	local w, h = self:getScreenSize()
	
	for idx, effect in pairs(self.player.statuseffects) do
		local text = effect.id..": "..math.floor(effect.time).."s"
		local f=love.graphics.getFont()
		local len = f:getWidth(text)
		-- background
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", w-(len+15), (idx)*12 + 5, len+5, 12, 5, 5)
		-- text
		love.graphics.setColor(1,1,1)
		love.graphics.printf(text, w-(len+15), idx*12+5, len+5, "center")
	end
end

function system:draw()

	if self.player.show_ui == false then return end
	love.graphics.push()
	love.graphics.origin()
	love.graphics.scale(uiscale, uiscale)
	love.graphics.setFont(guiutil.fonts.font_16)

	if self.player.spawntimer > 0 then
		local w, h = self:getScreenSize()
		love.graphics.setColor(0, 0, 0, 0.9)
		love.graphics.rectangle("fill", 0, 0, w, h)

		love.graphics.setColor(1,1,1)
		love.graphics.printf("Loading world, summoning player...", 0, h/2, w, "center")
	else
		self.slotPointingAt = -1
		self.recipeLookingAt = nil
		if self.open then

			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", 0, 0, self:getScreenSize())
			love.graphics.push()
			love.graphics.origin()
			menu:draw()
			love.graphics.pop()
			if not self.openContainer then
				self:drawRecipes()
				
			end
			self:drawFullInventory()
		else
			self.recipe_scroll = 0
			self:drawHotbar()
		end
		self:drawItemInCursor()
		self:drawStatusEffects()
	end
	love.graphics.pop()
	love.graphics.setFont(guiutil.fonts.default)
end

return system