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

	lead developer:
		joshuu o'leary - programming, game design, art

	supporting developers:
		karl darling - game design, business
		nate hayes - game design, testing

	contributors:
		bumpylegoman02 - bug testing & feedback
		BillyJ - bug testing & feedback
		Mescalyne - music, inspiring this project & teaching me many skills
		WheezyBackports - testing, feedback, fun ideas

	other credits:
		json.lua - JSON parser written by rxi.
		LOVE (Love2D) framework.
		Lua Programming Language
]]

function love.load(cmdlineargs)
	
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.filesystem.createDirectory("worlds")
	love.filesystem.createDirectory("screenshots")
	love.filesystem.createDirectory("data")
	
	local runMode = cmdlineargs[1]

	if runMode == "-editor" then
		require("src.editor")(cmdlineargs)
	elseif runMode == "-data" then
		require("src.data")(cmdlineargs)
	elseif runMode == "-analysis" then
		require("src.analyzer")(cmdlineargs)
	else
		require("src.gameloop")(cmdlineargs)
	end

end