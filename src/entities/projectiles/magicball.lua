local projectile = require("src.entities.projectiles.projectile")
local physicalentity = require("src.entities.physicalentity")
local jutils = require("src.jutils")
local tiles = require("src.tiles")

local magicball = projectile:subclass("MagicBall")

local magicballtexture = love.graphics.newImage("assets/entities/magicball.png")

function magicball:init(...)
	projectile.init(self, ...)


	--self.rotation = 
	print()

	self.rotation = math.rad(jutils.vec2.new(0, 0):angle(self.direction))
	self.power = 1
	self.texture = magicballtexture
	self.textureorigin = jutils.vec2.new(4,4)
	self.boundingbox = jutils.vec2.new(4, 4)
	self.mass = 0
	self.xfriction = 0

	self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 8, 8, 16, 8),-- standing still
		[2] = love.graphics.newQuad(8, 0, 8, 8, 16, 8),-- walking1,

	}


	self.scale = jutils.vec2.new(1, 1)
    self.save = false
    self.lightemitter = {1, 0, 1}

end
function magicball:collisionCallback(tileid, tilepos, separation, normal)

	local tiledata = tiles:getByID(tileid)

	if tiledata.solid == true then
        self.dead = true
	end
end

function magicball:entityCollision(otherEntity, separation, normal)
    self.dead = true
    otherEntity:damage(8)

end

function magicball:update(dt)
	projectile.update(self, dt)

	--self.timer = self.timer - dt

	-- time's up, let's explode
	--if self.timer < 0 then
	--	local world = self.world
--
    --local exp = world:addEntity("explosion", self.position, 8, 8, true)
	--end
end

function magicball:draw()
	love.graphics.setColor(self.light)

	local num = (math.floor(self.age) % 2) + 1

	local q = self.animationframes[num]
	love.graphics.draw(
		self.texture, q,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return magicball