local jutils = require("src.jutils")
local collision = require("src.collision")
local humanoid = require("src.entities.humanoid")

local zombie = humanoid:subclass("Zombie")

local badguytexture = love.graphics.newImage("assets/entities/badguy.png")


local zombie_types = {
	[1] = {
		health = 60,
		scale = 1.3,
		xfriction = 0.3,
		boundingbox = jutils.vec2.new(9, 18)
	},
	[2] = {
		health = 50,
		scale = 1.2,
		xfriction = 0.2,
		boundingbox = jutils.vec2.new(8, 16)
	},
	[3] = {
		health = 40,
		scale = 1.1,
		xfriction = 0.2,
		boundingbox = jutils.vec2.new(7, 14)
	},
	[4] = {
		health = 30,
		scale = 1,
		xfriction = 0.15,
		boundingbox = jutils.vec2.new(6, 12)
	},
	[5] = {
		health = 20,
		scale = 0.8,
		xfriction = 0.10,
		boundingbox = jutils.vec2.new(5, 10)
	}
}

function zombie:init()
	humanoid.init(self)

	local ztype = zombie_types[math.random(#zombie_types)]

	self.scale = jutils.vec2.new(ztype.scale, ztype.scale)
	self.displayname = "Zombie"
	self.hurt_yell_pitch = 0.75
	self.texture = badguytexture
	self.textureorigin = jutils.vec2.new(8, 12)
	self.boundingbox = ztype.boundingbox
	self.fallthrough = true
	self.mass = 1.25
	self.maxhealth = ztype.health
	self.health = ztype.health
	self.walkspeed = 30
	self.xfriction = ztype.xfriction
	self.direction = -1
	self.acceleration = 120
	self.attackCooldown = 0
	self.goal = jutils.vec2.new(0, 0)
	self.hostile = true
	self.stun = 0

	self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 16, 24, 64, 24),-- standing still
		[2] = love.graphics.newQuad(16, 0, 16, 24, 64, 24),-- walking1,
		[3] = love.graphics.newQuad(32, 0, 16, 24, 64, 24),--walking2
		[4] = love.graphics.newQuad(48, 0, 16, 24, 64, 24),--walking2
	}
end

function zombie:update(dt)
	humanoid.update(self, dt)


	self.jumping = false
	self.moveLeft = false
	self.moveRight = false
	self.fallthrough = false

	self.stun = self.stun - dt

	if self.stun < 0 then
		if self.goal.x > self.position.x then
			self.moveRight = true
			
		elseif self.goal.x < self.position.x then
			self.moveLeft = true
		end

		if (self.goal.y-10) > self.position.y then
			self.fallthrough = true
		end
	end

	if (self.moveLeft == true or self.moveRight == true) then
		if math.abs(self.velocity.x) < 20 then
			self.jumping = true
		end
		
	end

	-- TODO: optimize zombie
	local player = self.world:getPlayer()

	if player then

		local distance = self.position:distance(player.position)

		self.goal = player.position

		-- if they are close, then start considering collisions
		if distance < 20 then
			
			local mypos = self.nextposition
			local playerpos = player.nextposition

			local sx, sy = collision.test(
				mypos.x, mypos.y, self.boundingbox.x, self.boundingbox.y, 
				playerpos.x, playerpos.y, player.boundingbox.x, player.boundingbox.y
			)
			if sx~=nil and sy~=nil then
				local nx, ny = collision.solve(sx, sy, self.velocity.x-player.velocity.x, self.velocity.y-player.velocity.y)
				
				--self.nextposition = self.nextposition + jutils.vec2.new(sx, sy)
				--entity.nextposition = entity.nextposition - jutils.vec2.new(sx/2, sy/2)
				if self.attackCooldown < 0 and nx~=nil and ny~= nil then
					player:damage(10 + (math.random(10)) )
					if math.random() < 1/200 then
						player:addStatusEffect("INFECTION", 30)
					end
					player.velocity.x = player.velocity.x - nx*250
					player.velocity.y = -50
					self.attackCooldown = 0.5
				end
			end
		end
	end

	self.attackCooldown = self.attackCooldown - dt
end

function zombie:draw()
	humanoid.draw(self)
	local frame = self:getAnimationFrame()

	love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		self.animationframes[frame],
		self.position.x, self.position.y, self.rotation, self.scale.x* (-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return zombie