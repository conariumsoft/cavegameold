--[[
	cavegame project
	copyright 2019 Conarium Softare.

	--------------------------------------------------------------------------------------
	Permission is hereby granted to any entity obtaining this software to use, 
	modify, repurpose, and distribute all or portions of the software, including code,
	game art, and sound assets, for the purposes of fun, education, and entertainment. 

	You ARE permitted to:
	- Redistribute all or some of the software (ie. code) freely.
	- Make, redistribute and/or sell modifications ("Mods") to the software.
	- Use the code as you please, under condition of including this notice.

	You ARE NOT permitted to:
	- Sell the game without our (Conarium Software's) permission.
	- Steal our work and pass it off as your own.

	We can't realistically enforce this copyright notice,
	but please, don't be a dick. :)
	-------------------------------------------------------------------------------------

	Conarium Software:
	Karl Darling, Nate Hayes, Tyler Stewart, Joshua O'Leary, William Tomasine


	lead developer:
	Joshua "joshuu" O'Leary 	Programming, Art, Game Design, Content
	
	contributors:
	Nate "WheezyNewports" Hayes	Scripting, Art
	squidthonk
	
	support team:
	Karl Darling			Testing, Marketing Help
	William Tomasine		Testing
	Tyler Stewart			Business, Fun Testing

	special thanks to:
	"bumpylegoman02"		Stability Testing
	"squidthonkv2"			PlayTesting
	Evan Walter			Consultation, Moral Support
]]

function love.load(cmdlineargs)

	love.graphics.setDefaultFilter("nearest", "nearest")

	love.filesystem.setIdentity("cavegame")
	love.filesystem.createDirectory("worlds")
	love.filesystem.createDirectory("screenshots")
	love.filesystem.createDirectory("data")
	
	local runMode = cmdlineargs[1]
	if runMode == "-editor" then
		require("src.editor")(cmdlineargs)
	elseif runMode == "-data" then
		require("src.data")(cmdlineargs)
	else
		require("src.gameloop")(cmdlineargs)
	end
end

local funny_crash_messages = {
	"FUCK! I thought I fixed this.",
	"Something broke.",
	"Oops.",
	"REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.",
	"Sorry m8",
	"Josh fucked up again!",
	"We need to hire some better programmers.",
	"Don't be scared. This screen just means everything's wrong.",
	"My bad, i'll fix this soon.",
	"Please Stand By: Trained Codemonkeys have been dispatched to fix your game!",
	"You weren't supposed to know about the matrix...",
	"Your free trial of life has ended."
}

local utf8 = require("utf8")

math.randomseed(os.clock())
 
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
 
function love.errorhandler(msg)
	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
 
	love.graphics.reset()
	local font = love.graphics.setNewFont(14)
 
	love.graphics.setColor(1, 1, 1, 1)
 
	local trace = debug.traceback()
 
	love.graphics.origin()
 
	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)
 
	local err = {}
 
	local picked_funny = funny_crash_messages[math.random(#funny_crash_messages)]

	table.insert(err, picked_funny.."\n")
	table.insert(err, [[
		This is an error screen generated when the game crashes.
		If you see this, please take a screenshot and send to joshuu.
	]])
	table.insert(err, "Error occured at:\n"..sanitizedmsg)
 
	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end
 
	table.insert(err, "\n")
 
	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
 
	local p = table.concat(err, "\n")
 
	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
 
	local function draw()
		local pos = 20
		love.graphics.clear(0, 0, 0)
		love.graphics.setColor(0.25, 1, 0.25)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
 
	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end
 
	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end
 
	return function()
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
 
end