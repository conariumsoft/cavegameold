local config = require("config")
local tiles = require("src.tiles")
local jutils = require("src.jutils")

local physicalentity = require("src.entities.physicalentity")

local humanoid = physicalentity:subclass("Humanoid")

function humanoid:init()
	physicalentity.init(self)
	self.direction = -1 -- -1=left 0=forward 1=right
	self.walkspeed = 70
	self.acceleration = 1000
	self.climbcooldown = 0
	self.grabrope = false
	self.fallthrough = true
	self.statuseffects = {}
	self.knockbackTimer = 0
	self.humanoidControl = true
	self.mass = 1
	self.xfriction = 4
	self.jump_power = 300
	self.hurt_yell_pitch = 1
	self.animation = {
		running = false,
		walking = false,
		walkstep = 1,
		falling = false,
	}

	self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 16, 24, 64, 24),-- standing still
		[2] = love.graphics.newQuad(16, 0, 16, 24, 64, 24),-- walking1,
		[3] = love.graphics.newQuad(32, 0, 16, 24, 64, 24),--walking2
		[4] = love.graphics.newQuad(48, 0, 16, 24, 64, 24),--walking2
	}

	self.moveLeft = false
	self.moveRight = false
	self.moveUp = false
	self.moveDown = false
	self.jumping = false

	self.touchingrope = false
	self.grabrope = false
	self.onrope = false
end

function humanoid:collisionCallback(tileid, tilepos, separation, normal)
	physicalentity.collisionCallback(self, tileid, tilepos, separation, normal)
	if tiles:tileHasTag(tileid, "platformtile") then
		
		if normal.x == 0 and normal.y == -1 and self.fallthrough == false then

			local bottom = self.nextposition.y + self.boundingbox.y
			local realbottom = self.position.y + self.boundingbox.y

			local blockbottom = tilepos.y*config.TILE_SIZE+(config.TILE_SIZE/2)

			if realbottom <= blockbottom then
				self.nextposition = self.nextposition + separation
				self.falling = false
				self.velocity.y = 0
			end
		end
	end	

	if tiles:getByID(tileid).solid == true then
		if normal.y == 0 and normal.x ~= 0 then
			if self.velocity.y <= 0 and math.abs(self.velocity.x) > 2 then
				local tryY = tilepos.y*config.TILE_SIZE
				if tryY > self.nextposition.y and self.climbcooldown <= 0 then
					self.velocity.x = self.velocity.x * 0.6
					self.nextposition.y = (tryY-self.boundingbox.y)
					self.climbcooldown = 0.05
				end
			end
		end
	end
	
end

local humanoidAudio = love.audio.newSource("assets/audio/hurt.ogg", "static")

function humanoid:damage(amount)
	physicalentity.damage(self, amount)
	self.knockbackTimer = 0.25
	humanoidAudio:stop()
	humanoidAudio:setPitch(self.hurt_yell_pitch)
	humanoidAudio:play()

	local e = self.world:addEntity("floatingtext", jutils.math.round(amount, 0), {1, 0.1, 0})
	e:teleport(self.position)
	e.position = e.position + jutils.vec2.new(-10, -20)
end

function humanoid:addStatusEffect(effectid, duration)
	table.insert(self.statuseffects, {time = duration, id = effectid, handled = false})
end

function humanoid:fell(distance)
	
	distance = math.floor(distance/config.TILE_SIZE)
	
	if distance > 15 then
		self:damage(distance - 10)
	end
end

function humanoid:animation_update(dt)
	if self.animation.walking then
		self.animation.walkstep = (self.animation.walkstep + (dt* (math.abs(self.velocity.x)/10) ))
		if self.animation.walkstep >= 3 then
			self.animation.walkstep = 1
		end
	end
end

local effectlist = require("src.statuseffects")

function humanoid:statuseffect_update(dt)
	for idx, effect in pairs(self.statuseffects) do
		local effectdata = effectlist[effect.id]

		if effect.handled == false then
			effectdata.comeup(self)
			effect.handled = true
		end
		effect.time = effect.time - dt
		effectdata.tick(self, dt)
		
		if effect.time <= 0 then
			effectdata.comedown(self)
			effect = nil
			self.statuseffects[idx] = nil
		end
	end
end

function humanoid:getAnimationFrame()
	local actionframe = 1

	if self.falltime > 1/20 then
		actionframe = 4
	elseif self.animation.walking then
		actionframe = actionframe + math.floor(self.animation.walkstep)
	end

	return actionframe
end

function humanoid:updatePhysics(dt)
	self.touchingrope = false
	physicalentity.updatePhysics(self, dt)


	if self.touchingrope == true then
		if self.onrope == false then
			if self.moveUp == true or self.moveDown == true then
				self.onrope = true
				self.velocity.y = 0
			end
		end
	else
		self.onrope = false
	end
	self.applyGravity = not self.onrope

	local canJump = true
	if self.falling == true then canJump = false end
	if self.onrope == true then canJump = true end

	-- jumping
	if self.jumping and canJump then 
		self.velocity.y = -(self.jump_power*self.mass)
		self.falling = true
		self.onrope = false
	end

	if self.onrope == true then
		local rope_accelleration = 200
		if self.moveUp == true then self.velocity.y = self.velocity.y - (rope_accelleration) * dt end
		if self.moveDown == true then self.velocity.y = self.velocity.y + (rope_accelleration) * dt end
		
		if self.moveUp == false and self.moveDown == false then
			self.velocity.y = self.velocity.y / config.physics.FRICTION
		end
		self.velocity.y = jutils.math.clamp(-100, self.velocity.y, 100)

		--self.nextposition.x = math.floor(self.nextposition.x /config.TILE_SIZE)*config.TILE_SIZE + (config.TILE_SIZE/2)
	else

		self.animation.walking = false

		if self.knockbackTimer < 0 then
			-- left<->right movement
			if self.onrope == false then 
				if self.moveLeft == true then
					self.direction = -1
					self.animation.walking = true
					if self.velocity.x > -self.walkspeed then
						self.velocity.x = self.velocity.x - (self.acceleration) * dt
					end
				end
				if self.moveRight == true then
					self.direction = 1
					self.animation.walking = true
					if self.velocity.x < self.walkspeed then
						self.velocity.x = self.velocity.x + (self.acceleration) * dt
					end
				end
			end
		end
	end
end

function humanoid:update(dt)
	
	physicalentity.update(self, dt)

	self:animation_update(dt)
	self:statuseffect_update(dt)

	self.knockbackTimer = self.knockbackTimer - dt
	self.climbcooldown = self.climbcooldown - dt

end

return humanoid