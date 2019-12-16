local particle_module = {}

local particle_texture_sheet = love.graphics.newImage("assets/particles.png")

local tex_w, tex_h = particle_texture_sheet:getDimensions()

local particle_quads = {
    rectangle = love.graphics.newQuad(0, 0, 4, 4, tex_w, tex_h),
    small_rectangle = love.graphics.newQuad(4, 0, 4, 4, tex_w, tex_h),
    circle = love.graphics.newQuad(8, 0, 4, 4, tex_w, tex_h),
    cross = love.graphics.newQuad(12, 0, 4, 4, tex_w, tex_h),
    explosion_1 = love.graphics.newQuad(0, 12, 4, 4, tex_w, tex_h),
    explosion_2 = love.graphics.newQuad(4, 12, 4, 4, tex_w, tex_h),
}

local active_systems = {}

local new_mod = {}

function new_mod.new_static_psystem() end

function particle_module.newDefaultSystem()
    local sys = love.graphics.newParticleSystem(particle_texture_sheet, 100)

    table.insert(active_systems, sys)

    return sys
end

function particle_module.newExplosionSystem(position, radius)

    local linger = math.min(radius/15, 2)
    local min_linger_mult = 0.3
    local max_linger_mult = 1.5
    local density = math.min(10 + radius*4, 100)
    local size = 0.8
    local velocity = 50+(radius*2)
    
    local system = love.graphics.newParticleSystem(particle_texture_sheet, 100)
    system:setQuads(particle_quads.explosion_1, particle_quads.explosion_2)
	system:setPosition(position.x, position.y)
	system:setParticleLifetime(min_linger_mult*linger, max_linger_mult*linger)
	system:setEmissionArea("borderellipse", 4, 4, 0)
	system:setEmissionRate(0)
	system:setOffset(2, 2)
    system:setLinearDamping(2)
	system:setSpread(2*math.pi)
	system:setSizeVariation(1, 2.5)
	system:setSpeed(velocity)
	system:setSizes(4*size, size, 0.5)
	system:setColors(
		1,1,1, 1,
		0.5, 0.5, 0.5, 1
    )
    system:emit(density)

    table.insert(active_systems, system)
end

function particle_module.newBloodSplatter(position, gore)
    
    local system = love.graphics.newParticleSystem(particle_texture_sheet, 100)
    system:setQuads(particle_quads.explosion_1)
	system:setPosition(position.x, position.y)
	system:setParticleLifetime(0.5, 1)
	system:setEmissionArea("borderellipse", 6, 6, 0)
	system:setEmissionRate(0)
	system:setOffset(2, 2)
    system:setLinearDamping(1)
	system:setSpread(2*math.pi)
	system:setSizeVariation(0.5, 2.0)
    system:setSpeed(20)
    system:setLinearAcceleration(-30, 5, 60, 30)
	system:setSizes(2*gore, gore, 0.5)
	system:setColors(
		0.8, 0.0, 0.0, 0.5,
		0.5, 0.0, 0.0, 0
    )
    system:emit(gore*10)

    table.insert(active_systems, system)
end

function particle_module.newFire()
    local system = love.graphics.newParticleSystem(particle_texture_sheet, 50)
    system:setQuads(particle_quads.rectangle)
	system:setParticleLifetime(0.1, 0.65)
	system:setEmissionArea("normal", 3, 0, 0)
    system:setEmissionRate(45)
    system:setDirection(-math.pi/2)
    system:setRotation(0, math.pi*2)
	system:setOffset(2, 2)
    system:setLinearDamping(1)
    system:setSizeVariation(0.25, 1.25)
    system:setSizes(0.2, 0.75, 0.75, 0.1)
    system:setSpeed(45)
    system:setLinearAcceleration(-10, -60, 10, -30)
	system:setColors(
		0.9, 0.75, 0.3, 0.8,
		0.8, 0.05, 0.05, 0.8
    )
    --system:emit(15)

    --table.insert(active_systems, system)

    return system

end



function particle_module.update(dt)
    for index, system in pairs(active_systems) do

        system:update(dt)

        if system:getCount() == 0 then
           -- system:release()
           -- active_systems[index] = nil
        end
    end
end

-- TODO: create a better system
-- need ephemeral psystems (systems that exist briefly and are destroyed thereafter)
-- as well as systems that are passed back to the game and controlled by game scripts (while being pointer-safe)

function particle_module.draw()
    for _, system in pairs(active_systems) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(system, 0, 0)
    end
end

return particle_module