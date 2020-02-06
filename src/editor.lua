--- Structure editor.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
love.graphics.setBackgroundColor(0, 0, 0)

local jcon = require("src.jcon")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local rendering = require("src.rendering")
local jutils = require("src.jutils")
local input = require("src.input")

--[[ 
	todo list:

	different "tools" within the editor.
		stamp tool ()
		erase tool
		selection
		copy
		paste
		cut
		flip
		flood fill

	able to create multiple layers of tiles and backgrounds

	undo and redo functionality

	multi-tile objects able to be placed at once
	show list of tiles and bgs to change selection

	keybinds:
	ctrl+z - undo
	ctrl+y - redo
	ctrl+c - copy selection
	ctrl+v - paste clipboard
	ctrl+x - cut and copy clipboard
	scroll wheel - zoom
	right click - move window view
]]

local tmax = tiles:getNumberOfTiles()-1
local bmax = backgrounds:getNumberOfTiles()-1

local tmapsize = 64
local gridsize = 8

local current_tool = "stamp" 
--[[
	stamp
	fill
	remove
]]

local pointing_history = 1


local tilemap = {
	tiles = {},
	backgrounds = {},
	open = false,
	width = 0,
	height = 0,
}

local history = {
	[1] = {
		tiles = {},
		backgrounds = {},
	}
}

local is_panning = false

local view = {
	zoom = 2,
	magnification = 2,
	x = 0,
	y = 0,
	pointbg = false,
	selection = 1,
	bgselection = 1,
	showTiles = true,
	showBackgrounds = true,
	showAir = true,
}

local function grid_keyToCoordinates(key)
	local coords = jutils.string.explode(key, "_")
	return coords[1], coords[2]
end

local function grid_coordinatesToKey(x, y)
	local key = x .. "_" .. y
	return key
end

local function grid_pixelToTileXY(pixelx, pixely)
	local x = math.floor(pixelx / gridsize)
	local y = math.floor(pixely / gridsize)
	return x, y
end

local function getMouseKey()
	local mousex, mousey = input.getTransformedMouse()
	local mx, my = grid_pixelToTileXY(mousex, mousey)

	local key = grid_coordinatesToKey(mx, my)

	return key
end

local function map_get_background(key)
	return tilemap.backgrounds[key]
end

local function map_set_background(key, value)

	if map_get_background(key) ~= value then
		history[pointing_history] = {
			tiles = jutils.table.copy(tilemap.tiles),
			backgrounds = jutils.table.copy(tilemap.backgrounds),
		}

		pointing_history = pointing_history + 1

		tilemap.backgrounds[key] = value
	end
end

local function map_get_tile(key)
	return tilemap.tiles[key]
end

local function map_set_tile(key, value)
	
	if map_get_tile(key) ~= value then
		history[pointing_history] = {
			tiles = jutils.table.copy(tilemap.tiles),
			backgrounds = jutils.table.copy(tilemap.backgrounds),
		}

		pointing_history = pointing_history + 1

		tilemap.tiles[key] = value
	end
end

local commands = {
	["binds"]= {
		desc = "shows keybinds",
		func = function(args)
			jcon.message("b - toggle background and foreground layer", {0, 0, 0})
			jcon.message("o - toggle showing background layer", {0, 0, 0})
			jcon.message("p - toggle showing foreground layer", {0, 0, 0})
			jcon.message("l - toggle showing air", {0, 0, 0})
			jcon.message("left + right - change tile selection", {0, 0, 0})
			jcon.message("click - place tile", {0, 0, 0})
			jcon.message("click+e - erase tile", {0, 0, 0})
			jcon.message("click+ctrl - only replace air", {0, 0, 0})
			jcon.message("ctrl+z - undo", {0, 0, 0})
			jcon.message("shift+ctrl+z - undo 10x", {0, 0, 0})
			jcon.message("ctrl+u - redo", {0, 0, 0})
			jcon.message("shift+ctrl+u - redo 10x", {0, 0, 0})
		end,
	},
	["showfg"] = {
		desc = "",
		func = function(args)
			view.showTiles = not view.showTiles
			return
		end,
	},
	["showbg"] = {
		desc = "",
		func = function(args)
			view.showBackgrounds = not view.showBackgrounds
			return
		end,
	},
	["fg"] = {
		desc = "",
		func = function(args)
			view.pointbg = false
			return
		end,
	},
	["bg"] = {
		desc = "",
		func = function(args)
			view.pointbg = true
			return
		end,
	},
	["showair"] = {
		desc = "",
		func = function(args)
			view.showAir = not view.showAir
			rendering.enable_air(view.showAir)
			return
		end,
	},
	["load"] = {
		desc = "",
		func = function(args)
			local loaded = love.filesystem.load(args[1])()

			tilemap = {
				backgrounds = {},
				tiles = {},
			}
			
			for key, str in pairs(loaded.backgrounds) do
				tilemap.backgrounds[key] = backgrounds[str].id
			end
	
			for key, str in pairs(loaded.tiles) do
				tilemap.tiles[key] = tiles[str].id
			end
		
			return
		end,
	},
	["copy"] = {
		desc = "",
		func = function(args)
			local filename = args[1]
			local str = "return {\n"
			str = str.."\ttiles = {\n"
			for key, selection in pairs(tilemap.tiles) do
				local name = string.upper(tiles:getByID(selection).name)
				str = str .. ("\t\t[\""..key.."\"] = \""..name.."\",\n")
			end
				str = str.."\t},\n"
			str = str.."\tbackgrounds = {\n"
			for key, selection in pairs(tilemap.backgrounds) do
				local name = string.upper(backgrounds:getByID(selection).name)
				str = str .. ("\t\t[\""..key.."\"] = \""..name.."\",\n")
			end
				str = str.."\t}\n"
			str = str .."}"
			love.system.setClipboardText(str)
			return
		end,
	},
	["save"] = {
		desc = "saves the editor to disk.",
		func = function(args)
			local filename = args[1]
			local str = "return {\n"
			str = str.."\ttiles = {\n"
			for key, selection in pairs(tilemap.tiles) do
				local name = string.upper(tiles:getByID(selection).name)
				str = str .. ("\t\t[\""..key.."\"] = \""..name.."\",\n")
			end
				str = str.."\t},\n"
			str = str.."\tbackgrounds = {\n"
			for key, selection in pairs(tilemap.backgrounds) do
				local name = string.upper(backgrounds:getByID(selection).name)
				str = str .. ("\t\t[\""..key.."\"] = \""..name.."\",\n")
			end
				str = str.."\t}\n"
			str = str .."}"
			love.filesystem.write(filename, str)
			return
		end,
	},

	["select"] = {
		desc = "",
		func = function(args)
			if args[1] then
				local tile = string.upper(args[1])
				if view.pointbg then
					if backgrounds[tile] then
						view.selection = backgrounds[tile].id
						return
					end
				else
					if tiles[tile] then
						view.selection = tiles[tile].id
						return
					end
				end
			end
		end,
	},

	["quit"] = {
		desc = "quits the game",
		func = function(args)
			os.exit()
		end
	},
}

return function(args)

	_G.ENTITY_DEBUG = false
	_G.FULLBRIGHT = false
	_G.NO_TEXTURE = false

	love.window.setTitle("cavegame structure editor")
	love.window.setMode(1280, 720, {resizable = true, vsync = false})

	rendering.enable_air(view.showAir)
	
	-- callback for when user enters command into console
	jcon.commandListener:connect(function(command, args)
		if command == "help" then
			local param = args[1]
			if param then
				if commands[param] then
					jcon.message(commands[param].desc, {0, 0, 0.5})
					local usage = commands[param].arg or ""
					jcon.message("Usage: "..param.." "..usage, {0, 0, 0.5})
					return
				end
				jcon.message("ERROR: command '"..command.."' does not exist!", {1, 0, 0})
				return
			end
			jcon.message("Use 'list' to list all commands.", {0, 0, 0.5})
			return
		end

		if command == "list" then
			for name, data in pairs(commands) do
				local arg = data.arg or ""
				jcon.message(name.." "..arg.." : "..data.desc, {0, 0, 0.5})
			end
			return
		end

		if commands[command] then
			commands[command].func(args)
		else
			jcon.message("ERROR: command '"..command.."' does not exist!", {1, 0, 0})
		end
	end)

	function love.keypressed(key)
		jcon.keypressed(key)
		if jcon.open then
			
			return
		end

		if key == "b" then
			view.pointbg = not view.pointbg
		end

		if key == "o" then
			view.showBackgrounds = not view.showBackgrounds
		end

		if key == "p" then
			view.showTiles = not view.showTiles
		end

		if key == "l" then
			view.showAir = not view.showAir
			rendering.enable_air(view.showAir)
		end


		if love.keyboard.isDown("lctrl") then

			local inc = 1
			if love.keyboard.isDown("lshift") then
				inc = 10
			end

			if key == "u" then
				pointing_history = pointing_history + inc
				if pointing_history > #history then pointing_history = #history end
				tilemap.tiles = jutils.table.copy(history[pointing_history].tiles)
				tilemap.backgrounds = jutils.table.copy(history[pointing_history].backgrounds)
			end

			if key == "z" then
				print(pointing_history)
				pointing_history = pointing_history - inc
				if pointing_history < 1 then pointing_history = 1 end
				tilemap.tiles = jutils.table.copy(history[pointing_history].tiles)
				tilemap.backgrounds = jutils.table.copy(history[pointing_history].backgrounds)
			end
		end

		if key == "left" then
			if view.pointbg then
				view.bgselection = view.bgselection + 1
				if view.bgselection < 0 then view.bgselection = bmax end
				if view.bgselection > bmax then view.bgselection = 1 end
			else
				view.selection = view.selection + 1
				if view.selection < 0 then view.selection = tmax end
				if view.selection > tmax then view.selection = 1 end
			end
		end

		if key == "right" then
			if view.pointbg then
				view.bgselection = view.bgselection - 1
				if view.bgselection < 0 then view.bgselection = bmax end
				if view.bgselection > bmax then view.bgselection = 1 end
			else
				view.selection = view.selection - 1
				if view.selection < 0 then view.selection = tmax end
				if view.selection > tmax then view.selection = 1 end
			end
		end
	end
	
	function love.textinput(t)
		jcon.textinput(t)
	end
	
	function love.wheelmoved(x, y)

		view.magnification = view.magnification + (y/4)
		view.magnification = math.max(view.magnification, 0.5)
	
	end

	function love.mousemoved(x, y, dx, dy)
		if is_panning then
			view.x = view.x + (dx/view.zoom)
			view.y = view.y + (dy/view.zoom)
		end
	end
	
	function love.update(dt)

		view.zoom = jutils.math.lerp(view.zoom, view.magnification, 0.25)

		jcon:update(dt)
		rendering.update(dt)
	
		
		if love.mouse.isDown(1) then
			local mkey = getMouseKey()
	
			local erase_mode = love.keyboard.isDown("e")
			local careful_mode = love.keyboard.isDown("lctrl")
			
			-- erase mode

			
			if erase_mode then
				if view.pointbg then
					tilemap.backgrounds[mkey] = nil
				else
					tilemap.tiles[mkey] = nil
				end
			else

				-- careful tool (only overrides air)
				if careful_mode then
					if view.pointbg then
						if tilemap.backgrounds[mkey] == nil then
							map_set_background(mkey, view.bgselection)
						end
					else
						if tilemap.tiles[mkey] == nil then
							map_set_tile(mkey, view.selection)
						end
					end
				else
					if view.pointbg then
						map_set_background(mkey, view.bgselection)
					else
						map_set_tile(mkey, view.selection)
					end
				end
			end
		end
	
		if love.mouse.isDown(2) then
			if is_panning == false then
				is_panning = true
			end
		else
			if is_panning == true then
				is_panning = false
			end
		end
	
		if love.mouse.isDown(3) then
			local mkey = getMouseKey()
			if view.pointbg then
				if tilemap.backgrounds[mkey] then
					view.bgselection = tilemap.backgrounds[mkey]
				end
			else
				if tilemap.tiles[mkey] then
					view.selection = tilemap.tiles[mkey]
				end
			end
		end
	
		
		love.graphics.setColor(1,1,1)
	end
	
	function love.draw()
		
		love.graphics.push()
		love.graphics.translate((love.graphics.getWidth()/2), (love.graphics.getHeight()/2))
		love.graphics.scale(view.zoom, view.zoom)
		love.graphics.translate(view.x, view.y)
		local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
		input.setTransformedMouse(math.floor(mx), math.floor(my))
		
		local screen_half_width = love.graphics.getWidth()/2
		local screen_half_height = love.graphics.getHeight()/2

		--? this names suck but im fucking high right now
		local screen_grid_num_width = (love.graphics.getWidth()/2) / gridsize
		local screen_grid_num_height = (love.graphics.getHeight()/2) / gridsize

		love.graphics.setLineWidth(0.25)
		love.graphics.setColor(0.1, 0.1, 0.1)
		for y = -screen_grid_num_height, screen_grid_num_height do

			love.graphics.line(-screen_half_width, y*gridsize, screen_half_width, y*gridsize)

		end

		for x = -screen_grid_num_width, screen_grid_num_width do
			love.graphics.line(x*gridsize, -screen_half_height, x*gridsize, screen_half_height)
		end

		-- draw grid
		-- center line is thicker
		love.graphics.setLineWidth(1)
		love.graphics.setColor(1,1,1)
		love.graphics.line(-screen_half_width, 0, screen_half_width, 0)
		love.graphics.line(0, -screen_half_height, 0, screen_half_height)

		rendering.clearqueue()
	
		if view.showBackgrounds then
			for key, bgid in pairs(tilemap.backgrounds) do
				local x, y = grid_keyToCoordinates(key)
				rendering.queuebackground(bgid, 1, 1, 1, x, y)
			end
		end
		if view.showTiles then
			for key, tileid in pairs(tilemap.tiles) do
				local x, y = grid_keyToCoordinates(key)
				rendering.queuetile(tileid, 8, 0, 1, 1, 1, x, y)
			end
		end
	
		local mousex, mousey = input.getTransformedMouse()
		local mx, my = grid_pixelToTileXY(mousex, mousey)
		if view.pointbg then
			rendering.queuebackground(view.bgselection, 0.5, 0.5, 0.5, mx, my)
		else
			print(view.selection)
			rendering.queuetile(view.selection, 0, 0, 0.5, 0.5, 0.5, mx, my)
		end
		rendering.drawqueue()
		
		love.graphics.pop()
	
		-- draw topbar
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 30)

		love.graphics.setColor(0, 0, 0)
		if view.pointbg then
			local data = backgrounds:getByID(view.bgselection)
			love.graphics.print("selection(bg): "..data.name.."\tmouse: "..mx..", "..my, 0, 0)
		else
			local data = tiles:getByID(view.selection)
			love.graphics.print("selection(fg): "..data.name.."\tmouse: "..mx..", "..my, 0, 0)
		end

		local mkey = getMouseKey()
		local bglooking = tilemap.backgrounds[mkey]
	
		if bglooking then
			local bg = backgrounds:getByID(bglooking)
			love.graphics.print("bglooking: "..bg.name, 192, 16)
		end
	
		local tileLooking = tilemap.tiles[mkey]
		if tileLooking then
			local tile = tiles:getByID(tileLooking)
			love.graphics.print("tilelooking: "..tile.name, 0, 16)
		end
		jcon:draw()
	end
end