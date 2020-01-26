local jutils = require("src.jutils")
local config = require("config")
local entity = require("src.entities.entity")
local tiles = require("src.tiles")
local collision = require("src.collision")
local grid = require("src.grid")

local physicalentity = entity:subclass("PhysicalEntity")

function physicalentity:init()
	entity.init(self)
	
	self.velocity = jutils.vec2.new(0, 0)
	self.lastvalidposition = jutils.vec2.new(0, 0)
	self.mass = 1
	self.xfriction = 1
	self.frozen = false
	self.falldist = 0
	self.lastgroundy = 0
	self.falltime = 0
	self.falling = true
	self.fall_through_platforms = false
	self.noclip = false
	self.apply_gravity = true
	self.touching_lava = false
	self.touching_water = false
	self.internal_physics_step = 0
end

function physicalentity:teleport(point)
	entity.teleport(self, point)
	self.lastgroundy = point.y
	self.falldist = 0
	self.falltime = 0
end

function physicalentity:collisionCallback(tileid, tilepos, separation, normal)
	local data = tiles:getByID(tileid)
	if data.solid then

		if (normal.x == 1 or normal.x == -1) then
			if (separation.y == 0) then
				self.velocity.x = 0
			end
		end

		if normal.y == -1 then
			self.velocity.y = 0
			self.falling = false
		end

		if normal.y == 1 then
			self.velocity.y = -(self.velocity.y * 0.1)
		end
	end
end

function physicalentity:fell(distance)

end

local function testCollision(self, tilex, tiley)
	local tileid = self.world:getTile(tilex, tiley)
	if tileid == 0 then return false end
	if tileid == -1 then return false end

	local tiledata = tiles:getByID(tileid)
	if tiledata.collide == false then return false end

	local ex, ey, ew, eh = self.nextposition.x, self.nextposition.y, self.boundingbox.x, self.boundingbox.y

	local tx, ty, tw, th = (tilex*config.TILE_SIZE)+(config.TILE_SIZE/2), (tiley*config.TILE_SIZE)+(config.TILE_SIZE/2), config.TILE_SIZE/2, config.TILE_SIZE/2

	if tiledata.collisionBox then
		tx = tx + tiledata.collisionBox[1]
		ty = ty + tiledata.collisionBox[2]
		tw = tw - tiledata.collisionBox[3]
		th = th - tiledata.collisionBox[4]
	end

	local sx, sy = collision.test(ex, ey, ew, eh, tx, ty, tw, th)

	if not (sx and sy) then return false end

	local separation = jutils.vec2.new(sx, sy)

	local normalx, normaly = collision.solve(sx, sy, self.velocity.x, self.velocity.y)

	
	if tiledata.customCollision then
		local state = self.world:getTileState(tilex, tiley)
		tiledata.customCollision(self, separation, jutils.vec2.new(normalx, normaly), jutils.vec2.new(tilex, tiley), state)
	elseif tiledata.solid then-- default collision solver
		if normalx ~= nil and normaly ~= nil then
			self.nextposition = self.nextposition + separation
		end
	end
	self:collisionCallback(tileid, jutils.vec2.new(tilex, tiley), separation, jutils.vec2.new(normalx, normaly))
end

local pixelToTileXY = grid.pixelToTileXY

function physicalentity:collTest()
	if self.noclip == true then return end
	
	local entityTileX, entityTileY = pixelToTileXY(self.nextposition.x, self.nextposition.y)
	local extx, exty = pixelToTileXY(self.boundingbox.x+4, self.boundingbox.y+4)
	extx = extx
	exty = exty

	for x = -extx, extx do
		for y = -exty, exty do
			testCollision(self, entityTileX+x, entityTileY+y)
		end
	end
end

function physicalentity:updatePhysics(step)

	if self.frozen == false then

		-- air resistance / friction
		local force = (self.velocity.x * (config.physics.FRICTION * self.mass * self.xfriction) * step)
		self.velocity.x = self.velocity.x - force

		local yforce = (self.velocity.y * (config.physics.FRICTION) * self.mass * step)
		self.velocity.y = self.velocity.y - (yforce/2)

		if math.abs(self.velocity.x) < (1/80) then self.velocity.x = 0 end

		-- clamp horizontal velocity to walkspeed
		local TERMINAL = config.physics.TERMINAL_VELOCITY
		
		-- apply gravity if falling
		if self.falling and self.apply_gravity then
			if self.velocity.y < TERMINAL then
				self.velocity.y = self.velocity.y + ((config.physics.GRAVITY*self.mass)*step)
			end
			self.falltime = self.falltime + step
		else
			local falldist = self.nextposition.y - self.lastgroundy
			if falldist > 0 and self.falltime > 0.125 then
				if self.touching_lava == false and self.touching_water == false then
					self:fell(falldist)
				end
			end
			self.lastgroundy = self.nextposition.y
			self.falltime = 0
			
		end

		if self.velocity.y < -10 then
			self.lastgroundy = self.position.y
		end
		
		self.nextposition.x = self.nextposition.x + (self.velocity.x * step)
		self.nextposition.y = self.nextposition.y + (self.velocity.y * step)

		self.falling = true
	end
	self:collTest()
	self.position = self.nextposition

end

local debug_text = ""

local round = function(n) return jutils.math.round(n, 2) end

function physicalentity:update(dt)
	entity.update(self, dt)

	debug_text = "vel:".. round(self.velocity.x)..", ".. round(self.velocity.y) .."\n"..
				 "pos:".. round(self.position.x)..", ".. round(self.position.y).."\n"

	self.internal_physics_step = self.internal_physics_step + dt
	while self.internal_physics_step >= (1/60) do
		self.internal_physics_step = self.internal_physics_step - (1/60)
		self:updatePhysics(1/60)
	end

	if self.touching_lava then
		-- TODO: fix this shit fucktard
		self.health = self.health - (dt*10)
		if self:isA("Humanoid") then
			self:addStatusEffect("BURNING", 1)
		end
	end
	self.touching_lava = false
	self.touching_water = false
end

local crapfont = love.graphics.newFont()

function physicalentity:draw()
	entity.draw(self)

	if _G.ENTITY_DEBUG then
		love.graphics.push()
		love.graphics.scale(0.5, 0.5)
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(crapfont)
		love.graphics.print(debug_text, self.position.x*2 + 10, self.position.y*2 - 30)
		love.graphics.pop()
	end
end

return physicalentity
