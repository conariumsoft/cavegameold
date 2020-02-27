local jutils = require("src.jutils")
local tiles  = require("src.tiles")
local config = require("config")
local collision = require("src.collision")

local physicalentity = require("src.entities.physicalentity")



local tortured = physicalentity:subclass("Tortured")

local texture = love.graphics.newImage("assets/entities/tortured.png")


function tortured:init()
	physicalentity.init(self)

	self.displayname = "Tortured"
	self.texture = texture
	self.textureorigin = jutils.vec2.new(8, 8)
	self.boundingbox = jutils.vec2.new(8, 8)
	self.mass = 0
	self.maxhealth = 30
	self.health = 30
	self.scale = jutils.vec2.new(1, 1)

	self.goal_direction = jutils.vec2.new(math.random()-0.5, math.random()-0.5)
	
	self.pick_direction_timer = 0
	self.pissed_off = false
	self.pissed_timer = 0
	self.expand = 1
	self.booty = 1
end

function tortured:collisionCallback(tileid, tilepos, separation, normal)
	if tiles:getByID(tileid).solid == true then
		if normal.y ~= 0 and normal.x == 0 then
			if normal.y == -1 then
				self.velocity.y = -self.velocity.y*2
			end

			if normal.y == 1 then
				self.velocity.y = -self.velocity.y*2
			end
		end
	end
	physicalentity.collisionCallback(self, tileid, tilepos, separation, normal)
end

function tortured:update(dt)
	physicalentity.update(self, dt)

	self.pick_direction_timer = self.pick_direction_timer + dt

	if self.pick_direction_timer > 2 then
		self.pick_direction_timer = 0
		self.goal_direction = jutils.vec2.new(math.random()-0.5, math.random()-0.5)
	end

	self.velocity = self.velocity + (self.goal_direction*(dt*24))

	self.velocity.x = self.velocity.x * 0.999
	self.velocity.y = self.velocity.y * 0.999
	
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
				--self.nextposition = self.nextposition + jutils.vec2.new(sx, sy)
				--entity.nextposition = entity.nextposition - jutils.vec2.new(sx/2, sy/2)
				if self.pissed_off == false then
					self.pissed_off = true

				end
			end
		end
	end

	if self.pissed_off == true then
		self.booty = self.booty + (dt*3)
		self.pissed_timer = self.pissed_timer + dt
		self.expand = self.expand + (dt*self.booty)
		local warp = math.cos(self.expand)/8
		self.scale = jutils.vec2.new(warp+1, warp+1)

		if self.pissed_timer > 5 then
			self.world:addEntity("explosion", self.position, 10, 8, true)
			self.dead = true
		end
	end
end

function tortured:draw()
	love.graphics.setColor(self.light)

	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end


return tortured