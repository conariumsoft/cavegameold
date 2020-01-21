local jutils = require("src.jutils")
local collision = require("src.collision")
local humanoid = require("src.entities.humanoid")

local flower = humanoid:subclass("EvilFlower")

local dormant_flower_texture = love.graphics.newImage("assets/entities/flower.png")
local awake_flower_texture = love.graphics.newImage("assets/entities/angryflower.png")

function flower:init()
	humanoid.init(self)

	-- should be static properties
	self.mass = 1.10
	self.walkspeed = 30
	self.xfriction = 0.1
	self.hostile = true
	self.acceleration = 180
	self.maxhealth = math.random(15, 25)
	self.fallthrough = false
	self.scale = jutils.vec2.new(1, 1)
	self.displayname = "Flower"

	self.texture = dormant_flower_texture
	self.textureorigin = jutils.vec2.new(4, 8)
	self.boundingbox = jutils.vec2.new(4, 8)

	-- regular entity properties	
	self.health = self.maxhealth
	
	self.direction = -1
	self.attackCooldown = 0
	self.stun = 0
	self.dormant = true
	self.dormant_texture = true

	self.dormant_anim_timer = 0
	self.awake_anim_timer = 0

	self.dormant_frames = {
		[1] = love.graphics.newQuad(0, 0, 8, 16, 16, 16),
		[2] = love.graphics.newQuad(8, 0, 8, 16, 16, 16)
	}

	self.awake_frames = {
		[1] = love.graphics.newQuad(0, 0, 16, 24, 32, 24),-- walking1
		[2] = love.graphics.newQuad(16, 0, 16, 24, 32, 24),-- walking2,
	}
end

function flower:damage(amount)
	humanoid.damage(self, amount)

	self.dormant = false
end

function flower:update(dt)
	humanoid.update(self, dt)

	if self.dormant then
		self.dormant_anim_timer = self.dormant_anim_timer + dt
	else

		-- ? Remember to make this happen the other way around if the flower ever becomes able to go back to sleep
		if self.dormant_texture == true then
			self.dormant = false
			-- first changes from dormant to awake
			self.texture = awake_flower_texture
			self.boundingbox = jutils.vec2.new(8, 12)
			self.textureorigin = jutils.vec2.new(8, 12)
		end

		self.awake_anim_timer = self.awake_anim_timer + (dt* (math.abs(self.velocity.x)/8) )

		self.jumping = false
		self.moveLeft = false
		self.moveRight = false

		self.stun = self.stun - dt

		if self.stun < 0 then
			if self.position.x > self.goal.x then
				self.moveLeft = true
				self.direction = -1
			else
				self.moveRight = true
				self.direction = 1
			end
		end

	end

	for _, entity in pairs(self.world.entities) do
		if entity:isA("Player") then
			self.goal = entity.position
			
			local mypos = self.nextposition
			local entpos = entity.nextposition

			local sx, sy = collision.test(
				mypos.x, mypos.y, self.boundingbox.x, self.boundingbox.y, 
				entpos.x, entpos.y, entity.boundingbox.x, entity.boundingbox.y
			)
			if sx~=nil and sy~=nil then
				local nx, ny = collision.solve(sx, sy, self.velocity.x-entity.velocity.x, self.velocity.y-entity.velocity.y)
					
				if self.attackCooldown < 0 and nx~=nil and ny~= nil then
					entity:damage(5 + (math.random(10)) )
					entity.velocity.x = entity.velocity.x - nx*250
					entity.velocity.y = -50
					self.attackCooldown = 0.5
					self.dormant = false
				end
			end
		end
	end

	self.attackCooldown = self.attackCooldown - dt
end

function flower:draw()
	humanoid.draw(self)
	--local frame = self:getAnimationFrame()

	love.graphics.setColor(self.light)

	if self.dormant then

		local frame = (math.floor(self.dormant_anim_timer) % 2) + 1

		love.graphics.draw(
			dormant_flower_texture,
			self.dormant_frames[frame],
			self.position.x, self.position.y, self.rotation, self.scale.x* (-self.direction), self.scale.y,
			self.textureorigin.x, self.textureorigin.y
		)
	else

		local frame = (math.floor(self.awake_anim_timer) % 2) + 1

		-- NOTE: usually direction is negated in this snippet
		-- but flower's texture is facing the opposite direction of most humanoid 
		-- entities
		love.graphics.draw(
			awake_flower_texture,
			self.awake_frames[frame],
			self.position.x, self.position.y, self.rotation, self.scale.x* (self.direction), self.scale.y,
			self.textureorigin.x, self.textureorigin.y
		)
	end
end

return flower