
local jui = require("src.jui")
local config = require("config")

local jutils = require("src.jutils")
local settings_mod = require("src.settings")

local guiutil = require("src.guiutil")


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


local menu_module = {
	has_chosen_world = false,
	selected_world_name = "",
}

local function create_button(btn_text, actuationCallback)
	local button = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		borderColor = {1, 1, 0},
		pixelSize = jutils.vec2.new(0, 24),
		pixelPosition = jutils.vec2.new(0, 0),
		scaleSize = jutils.vec2.new(1, 0),
		scalePosition = jutils.vec2.new(0, 0),
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


local splash_ui = jui.scene:new({}, {
	text = jui.text:new({
		text = "conarium software",
		font = guiutil.fonts.font_30,
		textColor = jutils.color.fromHex("#FFFFFF"),
		textXAlign = "right",
		textYAlign = "center"
	})
})


local main_ui = jui.scene:new({}, {
	title_box = jui.rectangle:new({
		pixelSize = jutils.vec2.new(1000, 30),
		scaleSize = jutils.vec2.new(0, 0),
		pixelPosition = jutils.vec2.new(0, 30),
		scalePosition = jutils.vec2.new(0, 0),
		borderEnabled = false,
		backgroundColor = {0, 0, 0, 0}
	}, {
		title = jui.text:new({
			pixelSize = jutils.vec2.new(1000, 20),
			scaleSize = jutils.vec2.new(0, 0),
			text = "CAVE GAME",
			font = guiutil.fonts.font_40,
			textColor = jutils.color.fromHex("#FFFFFF"),
			textXAlign = "center",
			textYAlign = "top",
			
		})
	}),
	copyright_notice = jui.text:new({
		text = "v"..config.GAME_VERSION..", copyright conarium software",
		textColor = jutils.color.fromHex("#FFFFFF"),
		font = guiutil.fonts.font_12,
		textXAlign = "right",
		textYAlign = "bottom",

	}),
	buttonbox = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		borderEnabled = false,
		pixelSize = jutils.vec2.new(500, 200),
		pixelPosition = jutils.vec2.new(250, 300),
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
	box = jui.rectangle:new({
		pixelSize = jutils.vec2.new(500, 40),
		pixelPosition = jutils.vec2.new(256, 100),
		backgroundColor = {1, 1, 1, 0},
		borderEnabled = false,

	}, {
		txt = jui.text:new({
			text = "World Name:",
			textYAlign = "top",
			textXAlign = "center",
			textColor = {0.8, 0.8, 0.8},
			font = guiutil.fonts.font_16,
		}),
		input = world_name_input,
	}),
	

	infotext = jui.text:new({
		text = "Press Enter to confirm, or Escape to go back.",
		textYAlign = "bottom",
		textXAlign = "center",
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

local function get_world_saves()

	for idx, obj in pairs(world_menu_list) do
		world_menu_list[idx] = nil
	end

	for _, name in pairs(love.filesystem.getDirectoryItems("worlds")) do
		local data = love.filesystem.getInfo("worlds/"..name)
		local _, size = recursive_enumerate("worlds/"..name, "")


		if data then
			local box = world_load_box(name, os.date("%x %X", data.modtime)..", "..math.floor(size/(1000^2)).."mb")
			
			world_menu_list[#world_menu_list+1] = box
		end
	end
end

local function reset_load_menu_states()
	get_world_saves()
end

load_world_ui = jui.scene:new({}, {

	list = jui.rectangle:new({
		backgroundColor = {1, 1, 1, 0},
		pixelSize = jutils.vec2.new(800, 500),
		pixelPosition = jutils.vec2.new(50, 50),
	}, {
		button_list = jui.list:new({}, world_menu_list)

	}),
	infotext = jui.text:new({
		text = "Return - load, F8 - delete, F5 - open folder, ESC - back, ARROW - navigate",
		textYAlign = "bottom",
		textXAlign = "left",
		textColor = {0.8, 0.8, 0.8},
		font = guiutil.fonts.font_16,
	})
})
reset_load_menu_states()

settings_ui = jui.scene:new({}, {

})

credits_ui = jui.scene:new({}, {

	bottom = jui.text:new({
		scaleSize = jutils.vec2.new(0, 0),
		text = "Press Escape to go back.",
		font = guiutil.fonts.font_14,
		textColor = jutils.color.fromHex("#FFFFFF"),
		textXAlign = "center",
		textYAlign = "bottom",	
	}),
	credits_text = jui.text:new({
		pixelSize = jutils.vec2.new(1000, 20),
		scaleSize = jutils.vec2.new(0, 0),
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
"bumpylegoman02"
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

local splashtime = 0

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

	btn.actuation()
end

function menu_module.keypressed(key)
	if key == "up" then
		selected = selected - 1
	end

	if key == "down" then
		selected = selected + 1
	end

	selection_wrap_sanity_check()

	if key == "return" then
		if current_screen == new_world_ui then
			menu_module.has_chosen_world = true
			menu_module.selected_world_name = world_name_input.internalText
		elseif current_screen == load_world_ui then
			local buttonlist = current_screen:find("button_list")
		
			local btn = buttonlist.children[selected]
		
			menu_module.selected_world_name = btn.worldname
			menu_module.has_chosen_world = true
		else
			activate_button()
		end
		selected = 1
	end

	if key == "f8" and current_screen == load_world_ui then
		local buttonlist = current_screen:find("button_list")
		
		local btn = buttonlist.children[selected]
		
		recursive_delete("worlds/"..btn.worldname)
		reset_load_menu_states()
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

function menu_module.update(dt)
	current_screen:update(dt)


	if current_screen == splash_ui then
		splashtime = splashtime - dt

		if splashtime < 0 then
			current_screen = main_ui
		end
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

local img = love.graphics.newImage("assets/csoft.png")

function menu_module.draw()

	if current_screen == splash_ui then
		love.graphics.push()
		love.graphics.translate(love.graphics.getWidth()/4, love.graphics.getHeight()/2)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(img, 0, 0)

		love.graphics.pop()
	end
	current_screen:draw()
end


function menu_module.go_to_screen()

end

return menu_module