local jutils = require("src.jutils")
local input = require("src.input")
local guiutil = require("src.guiutil")

local physicalentity = require("src.entities.physicalentity")

local bee = physicalentity:subclass("Bee")
local beetexture = love.graphics.newImage("assets/entities/bee.png")

function bee:init()
	physicalentity.init(self)

	self.texture = beetexture
	self.boundingbox = jutils.vec2.new(4, 4)
	self.mass = 0
	self.direction = -1
	self.health = 15
	self.maxhealth = 15

	self.goalDirection = jutils.vec2.new(0, 0)
	self.fastSpeed = 400
	self.slowSpeed = 5
	self.pissedOff = false

	self.goalUpdateSpeed = 1/5
	self.goalUpdate = 3
	self.stung = false
	self.hostile = true
end

function bee:update(dt)
	physicalentity.update(self, dt)

	local world = self.world

	for _, entity in pairs(world.entities) do
		if entity:isA("Player") then
			local dist = self.position:distance(entity.position)

			if dist < 5 and self.stung == false then
				entity:damage(5)
				self.stung = true
				--self.dead = true
			end
		end
	end

	self.goalUpdate = self.goalUpdate + dt

	if self.goalUpdate > self.goalUpdateSpeed then
		self.goalUpdate = 0
		for _, entity in pairs(world.entities) do
			if entity:isA("Player") then
				self.goalDirection = entity.position
			end
		end
	end

	--self.goalDirection = jutils.vec2.new(input.getTransformedMouse())
	self.velocity = (self.position-self.goalDirection):unitvec() * -self.fastSpeed
	self.velocity = self.velocity + jutils.vec2.new(math.random()-0.5, math.random()-0.5)*10
end

function bee:draw()

	if math.ceil(self.health) < self.maxhealth then
		love.graphics.setFont(guiutil.fonts.font_8)
		love.graphics.setColor(0.8, 0, 0)
		love.graphics.printf(math.ceil(self.health).."/"..math.ceil(self.maxhealth).."HP", self.position.x-20, self.position.y-self.boundingbox.y-10, 40, "center")
		love.graphics.setFont(guiutil.fonts.default)
	end

	love.graphics.setColor(self.light)
	love.graphics.draw(self.texture,
		self.position.x, self.position.y, self.rotation,
		self.scale.x*(-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return bee