local jutils = require("src.jutils")

local humanoid = require("src.entities.humanoid")


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
end

function caster:update(dt)
	humanoid.update(self, dt)

	self.move_timer = self.move_timer + dt

	self.fireball_timer = self.fireball_timer + dt

	if self.move_timer > 1 then
		self.move_timer = 0
		local player = self.world:getPlayer()

		local goal = player.position:copy()

		self.moveRight = false
		self.moveLeft = false

		if goal.x > self.position.x then
			self.moveRight = true
		end

		if goal.x < self.position.x then
			self.moveLeft = true
		end

		if goal.x > self.position.y then
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

	love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x * (-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)

	humanoid.draw(self)
end

return caster
