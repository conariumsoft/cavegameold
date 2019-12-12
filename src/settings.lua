--- Module for getting and setting game options.
-- Also saves and loads game options between sessions.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local json = require("src.json")

local settingsfs = {}

local settings = {
	fullscreen = false,
	particles = true,
	volume = 25,
	gamescale = 2,
	autoscale = false,
	vsync = false,
	keyboard_player_move_left = "",
	keyboard_player_move_right = "",
	gamepad_player_move_left = "",
	gamepad_player_move_right = "",
}

local callbacks = {

}

---
function settingsfs.get(property)
	if settings[property] ~= nil then
		return settings[property]
	end

	error("No such configuration "..property, 2)
end

---
function settingsfs.set(property, value)

	if settings[property] ~= nil then
		settings[property] = value
		if callbacks[property] then
			for _, callback in pairs(callbacks[property]) do
				callback(value)
			end
		end
		return
	end
	error("No such configuration "..property, 2)
end

---
function settingsfs.changed(value, callback)
	if callbacks[value] == nil then
		callbacks[value] = {}

	end

	table.insert(callbacks[value], callback)
end

---
function settingsfs.save()
	local data = json.encode(settings)

	love.filesystem.write("settings.json", data)
end

---
function settingsfs.load()
	local info = love.filesystem.getInfo("settings.json")

	if info then
		local data = love.filesystem.read("settings.json")

		for option, value in pairs(json.decode(data)) do
			settings[option] = value
		end
	end

	for property, value in pairs(settings) do
		if callbacks[property] then
			for _, callback in pairs(callbacks[property]) do
				callback(value)
			end
		end
	end
end

return settingsfs