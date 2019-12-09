local grid = require("src.grid")
local jutils = require("src.jutils")
local config = require("config")
local entity = require("src.entities.entity")
local  tiles = require("src.tiles")

local explosion = entity:subclass("Explosion")
local settings = require("src.settings")

explosion.particle = love.graphics.newImage("assets/particles/explosion.png")

local explosion_sound = love.audio.newSource("assets/audio/explode.ogg", "static")


function explosion:init(position, radius, strength, damagetile)
	entity.init(self)
	self:teleport(position)
	self.radius = radius*config.TILE_SIZE
	self.strength = strength*config.TILE_SIZE
	self.damagetile = damagetile
	self.detonated = false
	self.linger = 0
	self.save = false

	local multi = radius/16

	self.system = love.graphics.newParticleSystem(self.particle, 300)
	self.system:setPosition(4, 4)
	self.system:setParticleLifetime(0.3*multi, (1.5*multi))
	self.system:setEmissionArea("borderellipse", 4, 4, 0)
	self.system:setEmissionRate(0)
	--self.system:setSpin(-2*math.pi, 2*math.pi)
	--self.system:setSpinVariation(1)
	self.system:setOffset(2, 2)
	self.system:setLinearDamping(2)
	self.system:setSpread(2*math.pi)
	self.system:setSizeVariation(1, 2.5)
	self.system:setSpeed(180*multi)
	--self.system:setRadialAcceleration(20, 20)
	--elf.system:setLinearAcceleration(-30, -30, 30, 30)
	self.system:setSizes(4*multi, multi, 0.5)
	self.system:setColors(
		1,1,1, 1,
		0.5, 0.5, 0.5, 1
	)
end

function explosion:dies()
	self.system:release()
end

function explosion:update(dt)

	if self.detonated == false then
		self.detonated = true
		--explosion_sound:stop()
		explosion_sound:play()
		if settings.get("particles") == true then
			self.system:emit(math.max(self.radius*2, 16))
		end

		for idx, entity in pairs(self.world.entities) do
			if entity ~= self and entity:isA("PhysicalEntity") then
				local dist = self.position:distance(entity.position)
				if dist <= self.radius+4 then

					local damage = math.min(math.max( (self.radius-dist)*2, 1), 200)

					entity:damage(damage)

					local unit = (entity.position-self.position):unitvec()
					
					if unit.y > 0 then
						unit.y = 0
					end
					
					local impart = unit *(self.strength*2)
					
					entity.velocity = entity.velocity + impart

					local terminalvelocity = config.physics.TERMINAL_VELOCITY
					entity.velocity.x = jutils.math.clamp(-terminalvelocity, entity.velocity.x, terminalvelocity)
					entity.velocity.y = jutils.math.clamp(-terminalvelocity, entity.velocity.y, terminalvelocity)

					
				end
			end
		end

		if self.damagetile then
			local tx, ty = grid.pixelToTileXY(self.position.x, self.position.y)

			local ex, ey = grid.pixelToTileXY(self.radius, self.radius)

			for dx = -ex, ex do
				for dy = -ey, ey do

					local dist = self.position:distance(jutils.vec2.new((tx+dx)*config.TILE_SIZE, (ty+dy)*config.TILE_SIZE))

					if dist <= self.radius then

						if self.world:getTile(tx+dx, ty+dy) == tiles.TNT.id then
							self.world:setTileState(tx+dx, ty+dy, 1)
							tiles.TNT.tileupdate(self.world, tx+dx, ty+dy)
						end

						local damage = math.ceil((self.radius-dist))/(self.radius*0.3)
						-- ? prevent damage of liquid tiles
						self.world:damageTile(tx+dx, ty+dy, damage)
						-- remove background?
						self.world:setBackground(tx+dx, ty+dy, 0)
					end
				end
			end
		end
	end

	if self.detonated then
		self.system:update(dt)
		self.linger = self.linger + dt
		if self.linger > 0.5 then
			self.dead = true
		end
	end
end

function explosion:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.system, self.position.x, self.position.y)
end

return explosion