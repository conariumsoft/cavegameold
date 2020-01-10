local jutils = require("src.jutils")
local guiutil = require("src.guiutil")

local entity = jutils.object:subclass("Entity")

local defaulttexture = love.graphics.newImage("assets/default.png")

function entity:init()
	
	self.dead = false
	self.age = 0 -- increases by 1 every second
	self.scale = jutils.vec2.new(1, 1)
	self.rotation = 0
	self.health = 100
	
	self.position = jutils.vec2.new(0,0)
	self.nextposition = jutils.vec2.new(0,0)
	self.world = nil
	self.unloadtimer = 0
	self.light = {1,1,1}
	self.invulnerability = 0
	
	self.defense = 0
	self.regenstrength = 0.01
	self.texture = defaulttexture
	self.textureorigin = jutils.vec2.new(4,4)
	self.boundingbox = jutils.vec2.new(4,4)
	self.maxhealth = 100
	self.save = false
	self.hostile = false
end

function entity:serialize()
	return {}
end

function entity:deserialize(serialdata)

end

function entity:collisionCallback(tileid, tilepos, separation, normal)
	
end

function entity:teleport(point)
	-- NOTE: tables are stored by REFERENCE in lua
	-- fix weird issue
	self.nextposition.x = point.x
	self.nextposition.y = point.y
	self.position.x = point.x
	self.position.y = point.y
end

function entity:damage(amount)
	if self.invulnerability <= 0 then
		amount = math.max(amount - self.defense, 1)
		self.health = self.health - amount
		self.invulnerability = 0.5
	end
end

function entity:dies()
	self = nil
end

function entity:update(dt)

	self.invulnerability = self.invulnerability - dt
	self.age = self.age + dt

	if self.health <= 0 then
		self.dead = true
		return
	end

	if self.unloadtimer ~= 0 then
		if self.age > self.unloadtimer then
			self.dead = true
		end
	end

	self.health = self.health + (self.regenstrength * dt)

	if self.health > self.maxhealth then
		self.health = self.maxhealth
	end
	
end

local ENTITY_DEBUG = false

function entity:draw()

	love.graphics.setFont(guiutil.fonts.font_8)
	love.graphics.setColor(0.8, 0, 0)
	local minus = 10
	if math.ceil(self.health) < self.maxhealth then
		
		love.graphics.printf(math.ceil(self.health).."/"..math.ceil(self.maxhealth).."HP", self.position.x-20, self.position.y-self.boundingbox.y-minus, 40, "center")
		minus = minus + 10
	end
	love.graphics.setFont(guiutil.fonts.default)

	if ENTITY_DEBUG then
		love.graphics.setLineWidth(0)
		love.graphics.setPointSize(2)
		love.graphics.setColor(1, 0, 0)
		love.graphics.points(self.position.x, self.position.y)

		love.graphics.setColor(0, 1, 0)
		love.graphics.points(self.position.x-self.textureorigin.x, self.position.y-self.textureorigin.y)

		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("line", self.position.x-self.boundingbox.x, self.position.y-self.boundingbox.y, self.boundingbox.x*2, self.boundingbox.y*2)
	end
end

return entity