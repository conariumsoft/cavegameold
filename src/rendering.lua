--- Batched tile rendering, and rendering utilities.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local items = require("src.items")
local config = require("config")
local renderer = {}

local tilesheet = love.graphics.newImage("assets/tilesheet.png")
local damageimage = love.graphics.newImage("assets/damage.png")

local spriteBatch = love.graphics.newSpriteBatch(tilesheet, 10000, "dynamic")
local damagebatch = love.graphics.newSpriteBatch(damageimage, 1000, "dynamic")

local frametimer = 0
local defaultQuad = love.graphics.newQuad(0, 0, 8, 8, 8, 8)

love.graphics.setDefaultFilter("nearest", "nearest")

local tilesheet = love.graphics.newImage("assets/tilesheet.png")

local textureReference = require("data.texturereference")

local properties = {
	draw_air = false,
	black_tiles_cull_texture = true, -- draws a blank quad over fully unlit tiles to improve speeds.
	no_textures = false,
	drawn_light_level_cap = 1.5,
}

function renderer.enable_air(val)
	_G.NO_TEXTURE = val
end

---
function renderer.update(dt)
	frametimer = frametimer + dt
end

local defaultQ = textureReference.tiles.blank


local config_tile_size = config.TILE_SIZE

---
function renderer.queuebackground(bgid, r, g, b, tx, ty)

	if properties.draw_air == false then
		if bgid == 0 then return true end
	--[[elseif bgid == 0 then
		spriteBatch:setColor(0.5, 0.5, 0.5, 0.5)
		spriteBatch:add(defaultQ, tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		return]]
	end

	if r == 0 and g == 0 and b == 0 then
		if properties.black_tiles_cull_texture then
			spriteBatch:setColor(0, 0, 0)
			spriteBatch:add(defaultQ, tx*config_tile_size, ty*config_tile_size)
			return true
		end
	end

	local data = backgrounds:getByID(bgid)

	local bgdim = 0.5
	-- cap visible light
	r = math.min(r, properties.drawn_light_level_cap)*bgdim
	g = math.min(g, properties.drawn_light_level_cap)*bgdim
	b = math.min(b, properties.drawn_light_level_cap)*bgdim

	local endr = data.color[1] * r
	local endg = data.color[2] * g
	local endb = data.color[3] * b
	spriteBatch:setColor(endr, endg, endb)

	local quad = data.texture

	if _G.NO_TEXTURE then
		quad = textureReference.tiles["blank"]
		spriteBatch:add(quad, tx*config_tile_size, ty*config_tile_size)
		return true
	end


	if data.animation then
		local animFrame = math.floor(frametimer * data.animationspeed)

		local animNum = (animFrame % (#data.animation)) + 1
		quad = data.animation[animNum]
	end

	local realQuad = textureReference.tiles[quad]
	if not realQuad then error(quad.." doesn't exist in textureReferences!") end
	spriteBatch:add(realQuad, tx*config_tile_size, ty*config_tile_size)
	
	return true
end

---
function renderer.queuetile(tileid, state, dmg, r, g, b, tx, ty)
	
	if properties.draw_air == false then
		if tileid == 0 then return true end
	elseif tileid == 0 then
		spriteBatch:setColor(1, 1, 1, 0.5)
		spriteBatch:add(defaultQ, tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		return
	end

	if r == 0 and g == 0 and b == 0 then
		if properties.black_tiles_cull_texture then
			spriteBatch:setColor(0, 0, 0)
			spriteBatch:add(defaultQ, tx*config.TILE_SIZE, ty*config.TILE_SIZE)
			return true
		end
	end

	local data = tiles:getByID(tileid)

	local maxdamage = data.hardness

	r = math.min(r, properties.drawn_light_level_cap)
	g = math.min(g, properties.drawn_light_level_cap)
	b = math.min(b, properties.drawn_light_level_cap)

	local endr = data.color[1] * r
	local endg = data.color[2] * g
	local endb = data.color[3] * b
	local a = data.color[4]

	if _G.NO_TEXTURE then
		local quad = textureReference.tiles["blank"]
		spriteBatch:add(quad, tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		return true
	end

	if data.layeredRender then

		local textures = data.layeredRender(tx, ty, state, dmg)
		
		for index, texdata in ipairs(textures) do
			local texturename = texdata[1]
			local rotation = texdata[2]

			local color = texdata[3]
			local endr = color[1] * r
			local endg = color[2] * g
			local endb = color[3] * b
			local a = color[4]
			spriteBatch:setColor(endr, endg, endb, a)
			spriteBatch:add(textureReference.tiles[texturename], (tx*config.TILE_SIZE)+4, (ty*config.TILE_SIZE) + 4, math.rad(rotation), 1, 1, 4, 4)
			
		end

		if dmg > 0 then
			damagebatch:setColor(1,1,1, dmg/maxdamage)
			local damageid = damagebatch:add(tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		end
		return true
	end

	if data.customRenderLogic then
		local texturename, color, rotation = data.customRenderLogic(tx, ty, state, dmg)
		--print("hack", texturename, color, rotation)
		texturename = texturename or data.texture
		color = color or data.color
		rotation = rotation or 0

		spriteBatch:setColor(color)
		spriteBatch:add(textureReference.tiles[texturename], (tx*config.TILE_SIZE) + 4, (ty*config.TILE_SIZE) + 4, math.rad(rotation), 1, 1, 4, 4)

		if dmg > 0 then
			damagebatch:setColor(1,1,1, dmg/maxdamage)
			local damageid = damagebatch:add(tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		end
		return true
	end

	-- cap visible light
	spriteBatch:setColor(endr, endg, endb, a)

	--! for some odd reason, liquid rendering is handled here, instead of having a customRenderLogic. fine with me.
	-- probably for the textureReference.liquids stuff...
	if tileid == tiles.WATER.id or tileid == tiles.LAVA.id or tileid == tiles.BLOOD.id then
		if state > 0 and state < 9 then
			spriteBatch:add(textureReference.liquids[state], tx*config.TILE_SIZE, ty*config.TILE_SIZE)
		end
		return true
	end

	local quad = data.texture

	if data.animation then
		local animFrame = math.floor(frametimer * data.animationspeed)

		local animNum = (animFrame % (#data.animation)) + 1
		quad = data.animation[animNum]
	end

	local realQuad = textureReference.tiles[quad]
	if not realQuad then error(quad.." doesn't exist in textureReferences!") end
	spriteBatch:add(realQuad, tx*config.TILE_SIZE, ty*config.TILE_SIZE)
	if dmg > 0 then
		damagebatch:setColor(1,1,1, dmg/maxdamage)
		local damageid = damagebatch:add(tx*config.TILE_SIZE, ty*config.TILE_SIZE)
	end
	
	return true
	
end

---
function renderer.drawqueue(x, y)
	love.graphics.draw(spriteBatch, x, y)
	love.graphics.draw(damagebatch, x, y)
end

---
function renderer.clearqueue()
	spriteBatch:clear()
	damagebatch:clear()
end

---
function renderer.drawItem(itemid, x, y, xscale, yscale, rotation, offx, offy)
	local data = items:getByID(itemid)

	local quad = defaultQuad

	love.graphics.setColor(data.color)
	local texture = data.texture

	if texture == "tiletexture" then
		quad = data.quad
		texture = tilesheet
	end
	if data.animation then
		local animFrame = math.floor(frametimer * data.animationspeed)

		local animNum = (animFrame % (#data.animation)) + 1
		quad = data.animation[animNum]

	end

	if type(quad) == "string" then
		quad = textureReference.tiles[quad]
	end

	love.graphics.draw(
		texture,
		quad,
		x,
		y,
		rotation,
		xscale,
		yscale,
		offx or 0,
		offy or 0
	)
end


function renderer.draw_item_detailed(itemid, x, y, xscale, yscale, rotation, offx, offy, light)
	love.graphics.setColor(light)
	

	local data = items:getByID(itemid)

	local quad = defaultQuad

	local color = {
		data.color[1] * light[1],
		data.color[2] * light[2],
		data.color[3] * light[3],
	}

	love.graphics.setColor(color)
	local texture = data.texture

	if texture == "tiletexture" then
		quad = data.quad
		texture = tilesheet
	end
	if data.animation then
		local animFrame = math.floor(frametimer * data.animationspeed)
		local animNum = (animFrame % (#data.animation)) + 1
		quad = data.animation[animNum]
	end

	if type(quad) == "string" then
		quad = textureReference.tiles[quad]
	end
	love.graphics.draw(texture, quad, x, y, rotation, xscale, yscale, offx or 0, offy or 0)
end

function renderer.drawTile(tileid, x, y, xscale, yscale, rotation, offx, offy)
	local data = tiles:getByID(tileid)

	local quad = data.texture

	if data.animation then
		local animFrame = math.floor(frametimer * data.animationspeed)

		local animNum = (animFrame % (#data.animation)) + 1
		quad = data.animation[animNum]

	end

	local finalQ = textureReference.tiles[quad]

	love.graphics.setColor(data.color)
	love.graphics.draw(
		tilesheet,
		finalQ,
		x,
		y,
		rotation,
		xscale,
		yscale,
		offx or 0,
		offy or 0
	)
end

return renderer
