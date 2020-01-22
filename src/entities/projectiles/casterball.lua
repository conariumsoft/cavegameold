local projectile = require("src.entities.projectiles.projectile")
local physicalentity = require("src.entities.physicalentity")
local jutils = require("src.jutils")
local tiles = require("src.tiles")

local caster_ball = projectile:subclass("CasterBall")

local magicballtexture = love.graphics.newImage("assets/entities/magicball.png")

function caster_ball:init(...)
	projectile.init(self, ...)


	self.rotation = math.rad(jutils.vec2.new(0, 0):angleBetween(self.direction))
	self.power = 1
	self.texture = magicballtexture
	self.textureorigin = jutils.vec2.new(4,4)
	self.boundingbox = jutils.vec2.new(4, 4)
	self.mass = 0
	self.xfriction = 0
	self.noclip = true

	self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 8, 8, 16, 8),-- standing still
		[2] = love.graphics.newQuad(8, 0, 8, 8, 16, 8),-- walking1,
	}

	self.scale = jutils.vec2.new(1, 1)
    self.save = false
    self.lightemitter = {1, 0, 1}

end
function caster_ball:collisionCallback(tileid, tilepos, separation, normal)

	--local tiledata = tiles:getByID(tileid)

	--if tiledata.solid == true then
      --  self.dead = true
--	end
end

function caster_ball:entityCollision(otherEntity, separation, normal)
    
   
	if otherEntity:isA("Player") then
		otherEntity:damage(15)
		self.dead = true
	end

end

function caster_ball:update(dt)
	projectile.update(self, dt)

	--self.timer = self.timer - dt

	-- time's up, let's explode
	--if self.timer < 0 then
	--	local world = self.world
--
    --local exp = world:addEntity("explosion", self.position, 8, 8, true)
	--end
end

function caster_ball:draw()
	love.graphics.setColor(self.light)

	local num = (math.floor(self.age) % 2) + 1

	local q = self.animationframes[num]
	love.graphics.draw(
		self.texture, q,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return caster_ball