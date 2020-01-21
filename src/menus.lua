
local jui = require("src.jui")
local config = require("config")

local jutils = require("src.jutils")
local settings_mod = require("src.settings")

local guiutil = require("src.guiutil")

local menu_worldtime = 16*60
local ambientlight = 0


----------------------------------------------
-- der util functions
local function recursive_enumerate(folder, filetree, fsize)

	local lfs = love.filesystem

	fsize = fsize or 0

	local files_table = lfs.getDirectoryItems(folder)

	for _, v in ipairs(files_table) do
		local file = folder.."/"..v

		local info = love.filesystem.getInfo(file)

		if info.type == "file" then
			fsize = fsize + info.size
			filetree = filetree .. "\n"..file
		elseif info.type == "directory" then
			filetree = filetree .. "\n" ..file.. " (DIR"
			filetree, fsize = recursive_enumerate(file, filetree, fsize)
		end
	end
	return filetree, fsize
end

local function recursive_delete(item)
	if love.filesystem.getInfo(item, "directory") then
		for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
			recursive_delete(item .. "/" .. child)
			love.filesystem.remove(item .. "/" .. child)
		end
	elseif love.filesystem.getInfo(item) then
		love.filesystem.remove(item)
	end
	love.filesystem.remove(item)
end

----

--[[
	outline:
	up & down - move selection
	left & right - slider actuation
	enter & space - button actuation
]]

local vec2 = jutils.vec2


local menu_module = {
	has_chosen_world = false,
	selected_world_name = "",
}

local function create_button(btn_text, actuationCallback)
	local button = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		borderColor = {1, 1, 0},
		pixelSize = vec2.new(0, 24),
		pixelPosition = vec2.new(0, 0),
		scaleSize = vec2.new(1, 0),
		scalePosition = vec2.new(0, 0),
		borderEnabled = false,
		actuation = actuationCallback
	}, {
		text = jui.text:new({
			text = btn_text,
			font = guiutil.fonts.font_20,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
		}),
	})
	return button
end

local current_screen

local credits_ui
local new_world_ui
local load_world_ui
local settings_ui

local img = love.graphics.newImage("assets/csoft.png")


local scene = jui.scene:new({}, {
	ttt = jui.text:new({
		text = "cum",
		
	})
})

local splash_ui = jui.scene:new({}, {
	rect = jui.layoutbox:new({
		scaleSize = jutils.vec2.new(0.75, 0.75),
		scalePosition = jutils.vec2.new(0.125, 0.125),
	}, {
		text = jui.text:new({
			text = "conarium software",
			font = guiutil.fonts.font_30,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "right",
			textYAlign = "center"
		}),
		logo = jui.image:new({
			image = img,
			pixelSize = jutils.vec2.new(256, 256),
			scalePosition = jutils.vec2.new(0.25, 0.5),
			pixelPosition = jutils.vec2.new(-128, -128)
		})
	})
})


local main_ui = jui.scene:new({}, {
	title_box = jui.layoutbox:new({
		pixelSize = vec2.new(0, 30),
		scaleSize = vec2.new(1, 0),
		pixelPosition = vec2.new(0, 30),
	}, {
		title = jui.text:new({
			text = "CAVE GAME",
			font = guiutil.fonts.font_40,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
			textYAlign = "center",
			
		})
	}),
	copyright_notice = jui.text:new({
		text = "v"..config.GAME_VERSION..", copyright conarium software",
		textColor = jutils.color.fromHex("#FFFFFF"),
		font = guiutil.fonts.font_12,
		textXAlign = "right",
		textYAlign = "bottom",

	}),
	buttonbox = jui.layoutbox:new({
		
		pixelSize = vec2.new(500, 200),
		scalePosition = vec2.new(0.5, 0.5),
		pixelPosition = vec2.new(-250, -100)
	}, {
		button_list = jui.list:new({}, {
			[1] = create_button("New World",  function()
				current_screen = new_world_ui
			end),
			[2] = create_button("Load World", function()
				current_screen = load_world_ui
			end),
			[3] = create_button("Settings",   function()
				current_screen = settings_ui
			end),
			[4] = create_button("Credits",    function()
				current_screen = credits_ui
			end),
			[5] = create_button("Quit Game",  function()
					love.event.quit()
			end),
		})
	})
})

local world_name_input = jui.textinput:new({
	defaultText = "New World",
	grabFocusOnReturn = true,
	clearOnReturn = false,
	clearTextOnFocus = true,
	clearDefaultOnFocus = true,
	isFocused = true,
	font = guiutil.fonts.font_16,
	textColor = {1, 1, 1},
	textXAlign = "center",
	textYAlign = "bottom",
	onInput = function(self, text)
		
	end
})

new_world_ui = jui.scene:new({}, {
	title_box = jui.layoutbox:new({
		pixelSize = vec2.new(0, 30),
		scaleSize = vec2.new(1, 0),
		pixelPosition = vec2.new(0, 30),
	}, {
		title = jui.text:new({
			text = "New World",
			font = guiutil.fonts.font_30,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
			textYAlign = "center",
			
		})
	}),
	box = jui.layoutbox:new({
		pixelSize = vec2.new(500, 40),
		scalePosition = vec2.new(0.5, 0.5),
		pixelPosition = vec2.new(-250, -20),
	
	}, {
		txt = jui.text:new({
			text = "World Name:",
			textYAlign = "top",
			textXAlign = "center",
			textColor = {0.8, 0.8, 0.8},
			font = guiutil.fonts.font_16,
		}),
		lilbox = jui.rectangle:new({
			scaleSize = vec2.new(0.5, 0.5),
			scalePosition = vec2.new(0.25, 0.5),
			backgroundColor = {0.15, 0.15, 0.15},
			borderColor = {0.25, 0.25, 0.25}
		}, {
			input = world_name_input,
		})
		
	}),
	

	infotext = jui.text:new({
		text = "ENTER: Confirm\tESCAPE: Back",
		textYAlign = "bottom",
		textXAlign = "left",
		textColor = {0.8, 0.8, 0.8},
		font = guiutil.fonts.font_16,
	}),
})

local function world_load_box(worldname, data)

	local box = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		scaleSize = jutils.vec2.new(1, 0),
		pixelSize = jutils.vec2.new(0, 20),
		worldname = worldname,
	}, {
		text = jui.text:new({
			text = worldname..data,
			textYAlign = "center",
			textXAlign = "left",
			textColor = {0.8, 0.8, 0.8},
			font = guiutil.fonts.font_16,
		}),
	})

	return box
end

local world_menu_list = {}

local longest = 0

local function get_world_saves()

	for idx, obj in pairs(world_menu_list) do
		world_menu_list[idx] = nil
	end

	for _, name in pairs(love.filesystem.getDirectoryItems("worlds")) do
		local data = love.filesystem.getInfo("worlds/"..name)
		local _, size = recursive_enumerate("worlds/"..name, "")


		if data then
			if #name > longest then
				longest = #name
			end
			local box = world_load_box(name, os.date("%x %X", data.modtime)..", "..math.floor(size/(1000^2)).."mb")
			
			world_menu_list[#world_menu_list+1] = box
		end
	end
end

local function reset_load_menu_states()
	get_world_saves()
end

load_world_ui = jui.scene:new({}, {
	title_box = jui.layoutbox:new({
		pixelSize = vec2.new(0, 30),
		scaleSize = vec2.new(1, 0),
		pixelPosition = vec2.new(0, 30),
	}, {
		title = jui.text:new({
			text = "Load World",
			font = guiutil.fonts.font_30,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
			textYAlign = "center",
			
		})
	}),
	list = jui.layoutbox:new({
		scaleSize = vec2.new(0.75, 0.8),
		pixelSize = vec2.new(0, -90),
		pixelPosition = vec2.new(0, 90),
		scalePosition = vec2.new(0.125, 0),
	}, {
		button_list = jui.list:new({}, world_menu_list)

	}),
	infotext = jui.text:new({
		text = "RETURN: Load\tF8: Delete\tESC: Back\tUP/DOWN: Navigate",
		textYAlign = "bottom",
		textXAlign = "left",
		textColor = {0.8, 0.8, 0.8},
		font = guiutil.fonts.font_16,
	})
})
reset_load_menu_states()


local function create_button(btn_text, actuationCallback)
	local button = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		borderColor = {1, 1, 0},
		pixelSize = vec2.new(0, 24),
		pixelPosition = vec2.new(0, 0),
		scaleSize = vec2.new(1, 0),
		scalePosition = vec2.new(0, 0),
		borderEnabled = false,
		actuation = actuationCallback
	}, {
		text = jui.text:new({
			text = btn_text,
			font = guiutil.fonts.font_16,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
		}),
	})
	return button
end

local function create_arrow_button(btn_text, activation)
	local button = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		borderColor = {1, 1, 0},
		pixelSize = vec2.new(0, 24),
		pixelPosition = vec2.new(0, 0),
		scaleSize = vec2.new(1, 0),
		scalePosition = vec2.new(0, 0),
		borderEnabled = false,
		arrow_activate = activation
	}, {
		text = jui.text:new({
			text = btn_text,
			font = guiutil.fonts.font_16,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",

		}),
	})
	return button
end

local function bool_to_english(val)
	if val == true then return "on" end
	if val == false then return "off" end
end

local s_fullscreen_btn
s_fullscreen_btn = create_button(
	"Fullscreen: ".. bool_to_english(settings_mod.get("fullscreen")),
	function()
		settings_mod.set("fullscreen", not settings_mod.get("fullscreen"))
		s_fullscreen_btn.children.text.text = "Fullscreen: ".. bool_to_english(settings_mod.get("fullscreen"))
	end
)

local s_vsync_btn

s_vsync_btn = create_button(
	"V-Sync: ".. bool_to_english(settings_mod.get("vsync")),
	function()
		settings_mod.set("vsync", not settings_mod.get("vsync"))
		s_vsync_btn.children.text.text = "V-Sync: ".. bool_to_english(settings_mod.get("vsync"))
	end
)

local s_particles_btn

s_particles_btn = create_button(
	"Particles: ".. bool_to_english(settings_mod.get("particles")),
	function()
		settings_mod.set("particles", not settings_mod.get("particles"))
		s_particles_btn.children.text.text = "Particles: ".. bool_to_english(settings_mod.get("particles"))
	end
)

local s_volume_slider
s_volume_slider = create_arrow_button(
	"Volume: ".. tostring(settings_mod.get("volume")),
	function(dir)
		local vol = settings_mod.get("volume")

		vol = vol + (dir*5)

		vol = math.max(vol, 0)
		vol = math.min(vol, 100)

		settings_mod.set("volume", vol)

		s_volume_slider.children.text.text = "Volume: ".. tostring(settings_mod.get("volume"))
	end

)

settings_ui = jui.scene:new({}, {
	title_box = jui.layoutbox:new({
		pixelSize = vec2.new(0, 30),
		scaleSize = vec2.new(1, 0),
		pixelPosition = vec2.new(0, 30),
	}, {
		title = jui.text:new({
			text = "Settings",
			font = guiutil.fonts.font_30,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
			textYAlign = "center",
			
		})
	}),

	options = jui.layoutbox:new({
		scaleSize = vec2.new(1, 1),
		pixelSize = vec2.new(0, -90),
		scalePosition = vec2.new(0, 0),
		pixelPosition = vec2.new(0, 90),
	}, {
		button_list = jui.list:new({}, {
			[1] = s_fullscreen_btn,
			[2] = s_particles_btn,
			[3] = s_volume_slider,
			[4] = s_vsync_btn,
		})
	})
})

credits_ui = jui.scene:new({}, {

	bottom = jui.text:new({
		text = "ESCAPE: Back",
		font = guiutil.fonts.font_14,
		textColor = jutils.color.fromHex("#FFFFFF"),
		textXAlign = "left",
		textYAlign = "bottom",
	}),
	credits_text = jui.text:new({
		text =
[[CAVE GAME
Developed by conarium software. Copyright 2019-2020.
_
Lead Developer
Joshua "joshuu" O'Leary
_
Contributors
Nate "WheezyNewports" Hayes
_
Support Team
Karl Darling - marketing
William Tomasine - testing & design
Tyler Stewart - business
_
Special Thanks To our Alpha Testers
"Bumpy"
"squidthonkv2"
Evan Walter
"bosswalrus"
"AndrewJ"
"Sorci"
]],
		font = guiutil.fonts.font_20,
		textColor = jutils.color.fromHex("#FFFFFF"),
		textXAlign = "center",
		textYAlign = "top",
	})
})

current_screen = splash_ui

local splashtime = 4

local selected = 1

local max_selected = 1

local function selection_wrap_sanity_check()
	if selected < 1 then selected = max_selected end
	if selected > max_selected then selected = 1 end
end

local function activate_button()
	local buttonlist = current_screen:find("button_list")

	if buttonlist == nil then return end

	local btn = buttonlist.children[selected]

	if btn.actuation then
		btn.actuation()
	end
end

local function arrow_activate(dir)
	local buttonlist = current_screen:find("button_list")

	if buttonlist == nil then return end

	local btn = buttonlist.children[selected]

	if btn.arrow_activate then
		btn.arrow_activate(dir)
	end
end

function menu_module.keypressed(key)
	if key == "up" then
		selected = selected - 1
	end

	if key == "down" then
		selected = selected + 1
	end

	if key == "j" then
		selected = selected + 1
	end

	if key == "k" then
		selected = selected - 1
	end

	selection_wrap_sanity_check()

	if key == "left" then
		arrow_activate(-1)
	end

	if key == "right" then
		arrow_activate(1)
	end

	if key == "return" then
		if current_screen == new_world_ui then
			menu_module.has_chosen_world = true
			menu_module.selected_world_name = jutils.string.sanitize(string.sub(world_name_input.internalText, 1, 32), "_")
		elseif current_screen == load_world_ui then
			local buttonlist = current_screen:find("button_list")
		
			local btn = buttonlist.children[selected]
			if btn then
				menu_module.selected_world_name = btn.worldname
				menu_module.has_chosen_world = true
			end
		else
			activate_button()
		end
		--selected = 1
	end

	if key == "f8" and current_screen == load_world_ui then
		local buttonlist = current_screen:find("button_list")
	
		local btn = buttonlist.children[selected]
		if btn then
			recursive_delete("worlds/"..btn.worldname)
			reset_load_menu_states()
		end
	end

	if key == "escape" then
		if current_screen == credits_ui or current_screen == load_world_ui or current_screen == new_world_ui or current_screen == settings_ui then
			current_screen = main_ui
			selected = 1
		end
	end

	if current_screen == new_world_ui then
		world_name_input:keypressed(key)
	end
end

function menu_module.joystickhat(joystick, hat, direction)
end

function menu_module.textinput(t)
	if current_screen == new_world_ui then
        world_name_input:textinput(t)
    end
end

local function get_daylight(worldtime)
	local light = 0.15
	local timeDial = worldtime

	if timeDial > (5.5*60)  and timeDial < (20*60)    then light = light + 0.15 end
	if timeDial > (5.75*60) and timeDial < (19.75*60) then light = light + 0.10 end
	if timeDial > (6*60)    and timeDial < (19.5*60)  then light = light + 0.10 end
	if timeDial > (6.25*60) and timeDial < (19.25*60) then light = light + 0.10 end
	if timeDial > (6.5*60)  and timeDial < (18.75*60) then light = light + 0.10 end
	if timeDial > (6.75*60) and timeDial < (18.5*60)  then light = light + 0.10 end
	if timeDial > (7.25*60) and timeDial < (18.25*60) then light = light + 0.10 end
	if timeDial > (7.5*60)  and timeDial < (18*60)    then light = light + 0.10 end
	return light
end

local base_menu_width = 1000
local base_menu_height = 600

local screen_ratio = 1

local colors = {
	[1] = {1, 0.5, 0.5},
	[2] = {1, 1, 0.5},
	[3] = {0.5, 1, 0.5},
	[4] = {0.5, 1, 1},
	[5] = {0.5, 0.5, 1},
}

local warp = 0

function menu_module.update(dt)
	menu_worldtime = menu_worldtime + (dt*15)

	if menu_worldtime > 1440 then
		menu_worldtime = 0
	end

	ambientlight = get_daylight(menu_worldtime)

	current_screen:update(dt)

	local c_screen_width = love.graphics.getWidth()
	local c_screen_height = love.graphics.getHeight()

	local h_ratio = c_screen_width/base_menu_width
	local v_ratio = c_screen_height/base_menu_height


	screen_ratio = math.min(h_ratio, v_ratio)

	if current_screen == splash_ui then
		splashtime = splashtime - dt

		if splashtime < 0 then
			current_screen = main_ui
		end

		warp = warp + (dt*2)

		local currentcolor = (math.floor(warp)%5)+1

		local lastcolor = currentcolor-1



		if lastcolor == 0 then
			lastcolor = #colors
		end

		--print(currentcolor, lastcolor)

		local splash_img = splash_ui:find("logo")

		splash_img.color = jutils.color.lerp(colors[lastcolor], colors[currentcolor], warp%1)

		local splash_text = splash_ui:find("text")

		splash_text.textColor = jutils.color.lerp(colors[lastcolor], colors[currentcolor], warp%1)
	end

	local buttonlist = current_screen:find("button_list")

	if buttonlist == nil then return end

	max_selected = #buttonlist.children

	for index, button in pairs(buttonlist.children) do
		if index == selected then
			--print(index, button)
			local textlabel = button:find("text")
			textlabel.textColor = {1, 0.5, 0.25}
		else
			local textlabel = button:find("text")
			textlabel.textColor = {1, 1, 1}
		end
	end

	
end




local cloud_bg_texture = love.graphics.newImage("assets/clouds.png")
local star_bg_texture = love.graphics.newImage("assets/stars.png")

function menu_module.draw()
	local sky_color = {0.05, 0.05, 0.05}

	local world_time_hour = menu_worldtime/60

	local daytime_color = {0.15, 0.35, 0.9}


	-- daytime
	if world_time_hour >= 9 and world_time_hour <= 17 then
		sky_color = daytime_color
		love.graphics.setColor(daytime_color)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end

	-- night time
	if world_time_hour >= 22 or world_time_hour <= 4 then

		sky_color = {0, 0, 0.01}
		love.graphics.setColor(sky_color)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end

	-- sunrise
	if world_time_hour >= 4 and world_time_hour <= 9 then

		local diff_time = ((menu_worldtime/60)-4)/5
		local top_color = jutils.color.multiply({diff_time, diff_time, diff_time}, daytime_color)
		local bottom_color = jutils.color.multiply({diff_time, diff_time, diff_time}, {1, 1, 0.15})

		local cucr = 0

		if world_time_hour > 6.75 then
			cucr = (world_time_hour-6.75)*2
		end

		for slice = 0, 20 do

			love.graphics.setColor(jutils.color.lerp(top_color, bottom_color, (slice/20)-cucr))
			love.graphics.rectangle("fill", 0, (love.graphics.getHeight()/20)*slice, love.graphics.getWidth(), love.graphics.getHeight()/20)
		end
	end

	-- sunset
	if world_time_hour >= 17 and world_time_hour <= 22 then
		local diff_time = 1-((menu_worldtime/60)-17)/5
		local top_color = jutils.color.multiply({diff_time, diff_time, diff_time}, daytime_color)
		local bottom_color = jutils.color.multiply({diff_time, diff_time, diff_time}, {0.75, 0.35, 0.15})

		local cucr = 0

		if world_time_hour < 19.25 then cucr = -((world_time_hour-19.25)*2) end

		if world_time_hour > 19.75 then cucr = (world_time_hour-19.75)*2 end

		for slice = 0, 20 do
			love.graphics.setColor(jutils.color.lerp(top_color, bottom_color, (slice/20)-cucr))
			love.graphics.rectangle("fill", 0, (love.graphics.getHeight()/20)*slice, love.graphics.getWidth(), love.graphics.getHeight()/20)
		end
	end

	-- TODO: make cloud layer scroll at 1.25 speed correctly!
	local bgscroll = 2
	local texsize = 512
	
	local x = (0) / bgscroll
	local y = 0 / bgscroll

	local posx = math.floor(x/texsize) 
	local posy = math.floor(y/texsize)
	
	for dx = -4, 4 do
		for dy = -3, 3 do
				
			local shiftx = x + ( (posx+dx)*texsize)
			local shifty = y + ( (posy+dy)*texsize)


			love.graphics.setColor(ambientlight, ambientlight, ambientlight, ambientlight)
			love.graphics.draw(cloud_bg_texture, shiftx, shifty, 0, 2, 2)
			love.graphics.setColor(1-ambientlight, 1-ambientlight, 1-ambientlight, 1-ambientlight)
			love.graphics.draw(star_bg_texture, shiftx, shifty, 0, 2, 2)
		end
	end

	current_screen:draw()
end


function menu_module.go_to_screen(screen)
	if screen == "main" then
		current_screen = main_ui
	end


	if screen == "splash" then

	end


	if screen == "settings" then

	end

	if screen == "credits" then

	end
end

return menu_module