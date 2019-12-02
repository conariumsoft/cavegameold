local jutils = require("src.jutils")
local physicalentity = require("src.entities.physicalentity")
local tiles = require("src.tiles")

local bat = physicalentity:subclass("Bat")

function bat:init()
	physicalentity.init(self)

	self.mass = 0
	self.xfriction = 1
	self.frozen = 0
	self.applyGravity = false
	self.boundingbox = jutils.vec2.new(8, 3)
	self.save = false
	self.goalDirection = jutils.vec2.new(math.random(1, 3)-2, 0)
	self.goalUpdateTimer = 0
	self.hostile = true
end
--[[
	Plans:
		bat attempts to get on same Y axis as player,
		then sweeps in from the side
]]
function bat:collisionCallback(tileid, tilepos, separation, normal)
	local data = tiles:getByID(tileid)
	if data.solid then
		if normal.x then
			self.velocity.x = self.velocity.x * normal.x
			self.goalDirection.x = self.goalDirection.x * -1
		end

		if normal.y then
			self.velocity.y = self.velocity.y * normal.y
		--	self.goalDirection.y = self.goalDirection.y * -normal.y
		end
	end
end

function bat:update(dt)
	physicalentity.update(self, dt)

	local target = self.world:getPlayer()

	self.goalUpdateTimer = self.goalUpdateTimer - dt

	if self.goalUpdateTimer < 0 then
		if self.position:distance(target.position) < 200 then
			print("within range")
	
			local direction = (target.position - self.position):unitvec()
	
			self.goalDirection.y = direction.y
		end
		self.goalUpdateTimer = 0.5
	end

	--self.velocity.y = self.velocity.y + self.goalDirection.y


	self.velocity = self.velocity + (self.goalDirection) + jutils.vec2.new(math.random(), math.random())

	
	
end

function bat:draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.points(self.position.x, self.position.y)

	love.graphics.setColor(0, 1, 0)
	love.graphics.points(self.position.x-self.textureorigin.x, self.position.y-self.textureorigin.y)

	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle("line", self.position.x-self.boundingbox.x, self.position.y-self.boundingbox.y, self.boundingbox.x*2, self.boundingbox.y*2)
end

return bat