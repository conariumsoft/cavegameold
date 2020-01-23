--- Item creation API and registry.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local jutils = require("src.jutils")
local object = jutils.object

local itemcollector = {}
local items = {}
local idinc = 1

love.graphics.setDefaultFilter("nearest", "nearest")

do
	function itemcollector:getByID(itemid)
		for name, data in pairs(items) do
			if data.id == itemid then
				return data
			end
		end
		error("No item with ID ".. itemid.. " exists!", 2)
	end

	function itemcollector:getNumberOfItems()
		return idinc
	end

	function itemcollector:getList()
		return items
	end

	local mt = {
		__index = function(t, k)
			if items[k] then return items[k] end
		end
	}
	setmetatable(itemcollector, mt)
end
---------------------------------------------------

local baseitem = object:subclass("Item") do
	--local self = baseitem
	baseitem.name = "GENERIC_ITEM"
	baseitem.displayname = "generic.Item"
	baseitem.stack = 2
	baseitem.repeating = true
	baseitem.speed = 1
	baseitem.rarity = 1
	baseitem.id = 1
	baseitem.texture = love.graphics.newImage("assets/default.png")
	baseitem.color = {1,1,1}
	baseitem.animation = nil
	baseitem.animationspeed = 0
	baseitem.defaultRotation = 0
	baseitem.inWorldScale = 1
	baseitem.playerHoldPosition = jutils.vec2.new(4, 4)
	baseitem.playeranim = {
		style = "swing",
		start = 0,
		distance = 90
	}

	--self.equip = function(self, player) end
	--self.unequip = function(self, player) end
	--self.leftuse = function(self, player) end
	--self.rightuse = function(self, player) end

	-- armour and accessory equip
	baseitem.equipped = function(self, player) end
	baseitem.unequipped = function(self, player) end

	baseitem.holdbegin = function(self, player) end
	baseitem.holdingStep = function(self, player, step) end
	baseitem.holdend = function(self, player) end

	--self.use = function() end

	--self.usestep = function(self, player, step)end
	--self.useend = function(self, player) end
end

function baseitem:init(name, data)
	--self:filldefaults()
	self.name = name
	self.displayname = name

	local latestID = idinc
	if data.id~=nil then
		latestID = data.id
	end

	--print("regitem", name, latestID)

	self.id = latestID
	idinc = latestID + 1

	-- override defaults
	for label, value in pairs(data) do
		if label == "texture" and type(value) == "string" and value ~= "tiletexture" then
			self["texture"] = love.graphics.newImage("assets/items/"..value)
		else
			self[label] = value
		end
	end

	items[name] = self
end

local usable = baseitem:subclass("UsableItem")
local consumable = usable:subclass("Consumable")
consumable.use = function(self, player)
	local result = self:consume(player)

	if result == true then
		local stack = player.itemHoldingStack
		stack[2] = stack[2]-1
		return true
	end
end

local function swinganim(start, dist)
	return {style = "swing", start = start, distance = dist}
end

local function pointanim(followmouse)
	return {style = "point", follow = followmouse}
end

local function jabanim(followmouse, length)
	return {style = "jab", follow = followmouse, length = length}
end

local itemEnvironment = {
	baseitem = baseitem,
	consumable = consumable,
	itemlist = items,
	itemmanager = itemcollector,
	swinganim = swinganim,
	pointanim = pointanim,
	jabanim = jabanim,
}
setmetatable(itemEnvironment, {__index = _G})

local files = love.filesystem.getDirectoryItems("data/items/")

for k, file in ipairs(files) do

	local d, errmsg = love.filesystem.load("data/items/"..file)
	if errmsg then print(errmsg) end
	setfenv(d, itemEnvironment)
	d()
end

return itemcollector