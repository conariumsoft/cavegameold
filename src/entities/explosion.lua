local grid 			 = require("src.grid")
local jutils 		 = require("src.jutils")
local config 		 = require("config")
local entity		 = require("src.entities.entity")
local tiles			 = require("src.tiles")
local particlesystem = require("src.particlesystem")
local settings		 = require("src.settings")


local explosion = entity:subclass("Explosion")

local explosion_sound = love.audio.newSource("assets/audio/explode.ogg", "static")

-- explosion entity
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
	if settings.get("particles") == true then
		particlesystem.newExplosionSystem(self.position, radius)
	end
	explosion_sound:play()
end

function explosion:update(dt)
	entity.update(self, dt)
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
	self.dead = true

end

function explosion:draw()
end

return explosion