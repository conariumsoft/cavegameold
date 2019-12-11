--- Cavegame's main loop. Controls menus, gamestate, and gameworld.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local config = require("config")
local grid = require("src.grid")
local jutils = require("src.jutils")

local items = require("src.items")
local input = require("src.input")
local rendering = require("src.rendering")
local jcon = require("src.jcon")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local settings = require("src.settings")
local world = require("src.world")

local menus = require("src.menus")


-- callback function for main.lua
-- this is needed to enable the same
-- program to run several different modes
-- ie. the game, structure editor, so on.
return function(args)

	local show_debug_info = false

	local in_menu = true
	local gameworld_autoscale = false
	local gameworld = nil
	local world_saved = false

	local debug_info_update = 0
	local last_debug_info = "collecting stats..."

	love.audio.setVolume(0.1)


	-- skip menu screens and load into world
	-- as well as enabling debug info

	settings.changed("volume", function(newvolume)
		--love.audio.setVolume(newvolume/100)
	end)

	settings.changed("fullscreen", function(val)
		love.window.setFullscreen(val)
	end)

	settings.changed("particles", function(val)
		-- TODO: make some kind of global flag for particles
	end)

	settings.changed("vsync", function(val)
		-- gotta restart to take effect
	end)


	settings.load()

	if args[1] == "-dev" then
		show_debug_info = true
		in_menu = false
		gameworld = world.new("dev_world", 0)
	end

	if args[1] == "-gen" then

		show_debug_info = true
		in_menu = false
		gameworld = world.new("gen_world", 0)
		gameworld.no_save = true
		gameworld.camera.zoom = 1.5
		gameworld.worldtime = 12*60
	end

	-- load into a specific world
	if args[1] == "-world" then
		in_menu = false
		-- TODO: sanity checks for second argument
		gameworld = world.new(args[2], 0)
	end

	-- skip splash
	if args[1] == "-nosplash" then
		menus.go("main")
	end

	if args[2] == "-nosave" then
		gameworld.no_save = true
	end

	love.window.setTitle("cavegame "..config.GAME_VERSION)
	love.window.setMode(
		1000, 600,
		{
			fullscreen = settings.get("fullscreen"),
			resizable = true,
			minwidth = 500,
			minheight = 300,
			vsync = settings.get("vsync")
		}
	)

	-- console command list
	local commands = {
		["fire"] = {
			desc = "",
			arg = "",
			func = function(args)
				local p = gameworld:getPlayer()
				p:addStatusEffect("BURNING", 30)
			end
		},
		["gimme"] = {
			desc = "gives the player an item",
			arg = "[itemname] [amount]",
			func = function(args)
				local amount = args[2] or 1
				local player = gameworld:getPlayer()
				local item = items[string.upper(args[1])]
				if item then
					player.gui.inventory:addItem(item.id, tonumber(amount))
				else
					jcon.message("Item "..args[1].. " does not exist!", {1, 0, 0})
				end
			end
		},
		["tp"] = {
			desc = "",
			func = function(args)

				local x = args[1]
				local y = args[2]

				if x == nil or y == nil then
					jcon.message("Must provide X and Y coordinates", {1, 0, 0})
					return
				end

				x = tonumber(x)
				y = tonumber(y)

				if type(x) ~= "number" or type(y) ~= "number" then
					jcon.message("Coordinates must be numbers", {1, 0, 0})
					return
				end

				local player = gameworld:getPlayer()

				player:teleport(jutils.vec2.new(x*8, y*8))
			end,
		},
		["freeze"] = {
			desc = "",
			func = function(args)
				local player = gameworld:getPlayer()

				player.frozen = not player.frozen
			end,
		},
		["itemlist"] = {
			desc = "",
			func = function(args)
				local list = items:getList()
				local itr = 0
				local message = ""
				for name, data in pairs(list) do
					itr = itr + 1
					message = message .. name .. ", "
					if itr > 6 then
						jcon.message(message, {0, 0, 0.5})
						message = ""
						itr = 0
					end
				end
			end,
		},
		["fullbright"] = {
			desc = "toggles game lighting",
			func = function(args)
				gameworld.debug_fullbright = not gameworld.debug_fullbright
			end
		},
		["respawn"] = {
			desc = "respawns the player.",
			func = function(args)
			end
		},
		["log"] = {
			desc = "",
			func = function(args)
			end,
		},
		["time"] = {
			desc = "",
			func = function(args)
				if args[1] then
					local t = tonumber(args[1])
					if t then
						gameworld.worldtime = t
					end
				else
					jcon.message("Time: "..math.floor(gameworld.worldtime).."gt or "..jutils.math.round(gameworld.worldtime/60, 1).." hours", {0, 0, 0.5})
				end
			end
		},
		["randtick"] = {
			desc = "",
			func = function(args)
				if args[1] then
					local t = tonumber(args[1])
					if t then
						gameworld.random_tick_speed = t
					end
				else
					jcon.message("RandomTickRate: "..gameworld.random_tick_speed, {0, 0, 0.5})
				end
			end,
		},
		["summon"] = {
			desc = "spawns an entity at player's position",
			arg = "[entity]",
			func = function(args)
				local e = gameworld:addEntity(args[1], args[2], args[3], args[4], args[5]) -- ugly quick hack, fix later
				e:teleport(gameworld:getPlayer().position)
			end
		},
	
		["settile"] = {
			desc = "",
			func = function(args)
	
			end
		},
	
		["quit"] = {
			desc = "quits the game",
			func = function(args)
				os.exit()
			end
		},
	
		["exit"] = {
			desc = "leaves the gameworld and returns to menu",
			func = function(args)
				
			end,
		}
	}
	
	-- callback for when user enters command into console
	jcon.commandListener:connect(function(command, args)
		if command == "help" then
			local param = args[1]
			if param then
				if commands[param] then
					jcon.message(commands[param].desc, {0, 0, 0.5})
					local usage = commands[param].arg or ""
					jcon.message("Usage: "..param.." "..usage, {0, 0, 0.5})
				else
					jcon.message("ERROR: command '"..command.."' does not exist!", {1, 0, 0})
				end
			else
				jcon.message("Use 'list' to list all commands.", {0, 0, 0.5})
			end
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


	local function update_debug_info()

		local mx, my = input.getTransformedMouse()


		local tx, ty = grid.pixelToTileXY(mx, my)

		local tileid = gameworld:getTile(tx, ty)
		local tiledata = tiles:getByID(tileid)
		local tilestate = gameworld:getTileState(tx, ty)
		local bgid = gameworld:getBackground(tx, ty)
		local bgdata = backgrounds:getByID(bgid >= 0 and bgid or 0)
		

		local light = gameworld:getLight(tx, ty)
		local player = gameworld:getPlayer()

		if player then

			local plrGridX, plrGridY = grid.pixelToTileXY(player.position.x, player.position.y)

			local graphicsStats = love.graphics.getStats()

			last_debug_info = "fps: "..love.timer.getFPS()..", lvm: ".. jutils.math.round(collectgarbage("count")/1024, 1).."mb"..
						" dt: "..jutils.math.round(1000*love.timer.getAverageDelta(), 1).."ms"..
						" txm: "..jutils.math.round(graphicsStats.texturememory/1024, 1).."kb, dc: "..graphicsStats.drawcalls..", i: "..graphicsStats.images..
						" dcb: "..graphicsStats.drawcallsbatched..", f: "..graphicsStats.fonts.."\n"..
						"tile: "..tileid.." name: "..tiledata.name..
						" state: "..tilestate.." bg: "..bgid.." name: "..bgdata.name..
						" light: "..light[1]..", "..light[2]..", "..light[3]..
						" dmg: "..gameworld:getTileDamage(tx, ty).."\n"..
						"pos: "..plrGridX..", "..plrGridY.." vel: "..jutils.math.round(player.velocity.x, 1)..", "..jutils.math.round(player.velocity.y, 1)..
						" entities: "..(#gameworld.entities)

		end
	end

	function love.update(dt)
		if in_menu then
			menus.update(dt) 
			
			if menus.world_chosen == true then
				print(menus.selected_world)
				in_menu = false
				gameworld = world.new(menus.selected_world, 0)
			end
		elseif gameworld then

			if show_debug_info then
				debug_info_update = debug_info_update + dt

				if debug_info_update > (0.1) then
					debug_info_update = 0
					update_debug_info()
				end
			end

			if jcon.open then
				jcon:update(dt)
			else
				gameworld:update(dt)
				rendering.update(dt)

				if gameworld.tryingToEnd == true then
					if world_saved == false then
						world_saved = true
						gameworld.tryingToEnd = true
						gameworld:savedata()
						in_menu = true
						-- TODO: confirm that gameworld gets fully cleaned up after exit
						gameworld = nil
					end
				end
			end
		end
	end

	function love.quit()
		if gameworld then
			gameworld.tryingToEnd = true
			gameworld:savedata()
		end

		settings.save()
	end

	function love.wheelmoved(x, y)
		input.wheelmoved:call(x, y)
	end
	
	function love.keypressed(key)
		if gameworld then
			jcon.keypressed(key)
		else
			menus.keypressed(key)
		end
		input.keypressed:call(key)
	end
	
	function love.keyreleased(key)
		
		input.keyreleased:call(key)
	end
	
	function love.mousepressed(x, y, button, istouch, presses)
		input.mousepressed:call(x, y, button, istouch, presses)
	end
	
	function love.mousereleased(x, y, button, istouch, presses)
		input.mousereleased:call(x, y, button, istouch, presses)
	end
	
	function love.textinput(t)
		if gameworld then
			jcon.textinput(t)
		else
			menus.textinput(t)
		end
		input.textinput:call(t)
	end

	function love.draw()

		if in_menu then
			menus.draw()
		elseif gameworld then
			gameworld:draw()

			if show_debug_info then
				love.graphics.setColor(0,0,0, 0.5)
				love.graphics.rectangle("fill", 2, 2, 500, 48)
				love.graphics.setColor(1,1,1)
				love.graphics.print(last_debug_info, 2, 2)

			else
				love.graphics.setColor(1,1,1)
				love.graphics.print("fps: "..love.timer.getFPS(), 2, 2)
			end

			jcon:draw()
		end
	end
end