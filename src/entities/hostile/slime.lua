local jutils = require("src.jutils")
local collision = require("src.collision")

local humanoid = require("src.entities.humanoid")

local slime = humanoid:subclass("Slime")
local slimetexture = love.graphics.newImage("assets/entities/slime.png")

function slime:init(size)
    size = size or 1
    humanoid.init(self)

    self.save = false
    self.texture = slimetexture
    self.boundingbox = jutils.vec2.new(8*size, 8*size)
    self.textureorigin = jutils.vec2.new(8*size, 8*size)
    
    self.direction = 1
    self.maxhealth = 10*size
    self.health = 10*size
    self.mass = 1
    self.hostile = true
    self.xfriction = 0.25
    self.attackCooldown = 0

    self.hop_direction = -1

    self.hop_timer = 0

   --[[ self.animationframes = {
		[1] = love.graphics.newQuad(0, 0, 16, 16, 48, 16),-- standing still
		[2] = love.graphics.newQuad(16, 0, 16, 16, 48, 16),-- walking1,
		[3] = love.graphics.newQuad(32, 0, 16, 16, 48, 16),--walking2
	--	[4] = love.graphics.newQuad(48, 0, 16, 16, 48, 16),--walking2
	}]]
end

function slime:updatePhysics(step)
    humanoid.updatePhysics(self, step)

   -- self.velocity.x = self.velocity.x + self.direction
end


function slime:collisionCallback()
    --self.velocity.x = 0
end

function slime:update(dt)
    humanoid.update(self, dt)


    self.hop_timer = self.hop_timer + dt

    self.jumping = false
    if self.hop_timer > 2.5 then
        self.hop_timer = 0
        self.jumping = true
        self.velocity.x = self.velocity.x + (80*self.hop_direction)
        self.velocity.y = -300
    end

    local p = self.world:getPlayer()

    if p then

        if p.position.x > self.position.x then
            self.hop_direction = 1
        else
            self.hop_direction = -1
        end

        local mypos = self.nextposition
		local entpos = p.nextposition

		local sx, sy = collision.test(
			mypos.x, mypos.y, self.boundingbox.x, self.boundingbox.y,
			entpos.x, entpos.y, p.boundingbox.x, p.boundingbox.y
		)
		if sx~=nil and sy~=nil then
			local nx, ny = collision.solve(sx, sy, self.velocity.x-p.velocity.x, self.velocity.y-p.velocity.y)
				
            if self.attackCooldown < 0 and nx~=nil and ny~= nil then
                p:damage(5 + (math.random(10)) )
				p.velocity.x = p.velocity.x - nx*250
				p.velocity.y = -50
				self.attackCooldown = 0.5
            end

        end

    end
    self.attackCooldown = self.attackCooldown - dt
end

function slime:draw()
    love.graphics.setColor(self.light)
   -- local quad = math.floor(self.age % 3) + 1
    love.graphics.draw(self.texture,
       -- self.animationframes[quad],
		self.position.x, self.position.y, self.rotation,
		self.scale.x*(-self.direction), self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return slime