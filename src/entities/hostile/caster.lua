local jutils = require("src.jutils")

local humanoid = require("src.entities.humanoid")

local items = require("src.items")

local caster = humanoid:subclass("Caster")

local casterTexture = love.graphics.newImage("assets/entities/caster.png")

function caster:init()
	humanoid.init(self)

	self.boundingbox = jutils.vec2.new(12, 18)
	self.textureorigin = jutils.vec2.new(12, 18)

	self.displayname = "Caster"
	self.hurt_yell_pitch = 1.25
	self.texture = casterTexture
	self.mass = 1.5
	self.maxhealth = 30
	self.health = 30
	self.stun = 0
	self.jump_wait = 0
	self.apply_gravity = false
	self.hostile = true
	self.move_timer = 0
	self.fireball_timer = 0

	self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 24, 36, 48, 36),
		[2] = love.graphics.newQuad(24, 0, 24, 36, 48, 36),
	}
end

function caster:updatePhysics(dt)
	humanoid.updatePhysics(self, dt)

	if self.moveUp == true then
		self.velocity.y = -20
	end

	if self.moveDown == true then
		self.velocity.y = 20
	end
end

function caster:dies()

	local roll = math.random()

	if roll < (1/300) then
		local itemstack = self.world:addEntity("itemstack", items.WICKED_FLAME.id, 1)
		itemstack:teleport(self.position:copy())
	end

	humanoid.dies(self)
end

function caster:update(dt)
	humanoid.update(self, dt)

	self.move_timer = self.move_timer + dt

	self.fireball_timer = self.fireball_timer + dt

	if self.move_timer > 2 then
		self.move_timer = 0
		local player = self.world:getPlayer()

		local goal = player.position + jutils.vec2.new(0, -20)

		self.moveRight = false
		self.moveLeft = false
		self.moveDown = false
		self.moveUp = false

		if goal.x > self.position.x then
			self.moveRight = true
		end

		if goal.x < self.position.x then
			self.moveLeft = true
		end

		if goal.y > self.position.y then
			self.moveDown = true
		end

		if goal.y < self.position.y then
			self.moveUp = true
		end
	end

	if self.fireball_timer > 5 then
		self.fireball_timer = 0

		local player = self.world:getPlayer()

		local start = self.position:copy()
		local goal = player.position:copy()

		if goal:distance(start) < 50 then

			local propulsion = 90
			local mass = 0.5

			local caster_ball = self.world:addEntity("casterball", start, goal, propulsion, mass)
		end
	end
end

function caster:draw()
	local num = 1

	if self.fireball_timer > 4 then
		num = 2
	end

	local q = self.animationframes[num]

	love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		q,
		self.position.x, self.position.y, self.rotation, self.scale.x * (-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)

	humanoid.draw(self)
end

return caster
