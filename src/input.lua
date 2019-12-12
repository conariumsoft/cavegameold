--- User input utilities and weird workarounds.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software


local input_module = {}

local events = {
	keypressed = {},
	textinput  = {},
	keyreleased = {},
	mousemoved = {},
	wheelmoved = {},
	mousepressed = {},
	mousereleased = {},
	gamepadpressed = {},
	gamepadreleased  = {},
}

local function fire_callbacks(event, ...)
	for _, callback in pairs(events[event]) do
		callback(...)
	end
end

function love.keypressed(...) fire_callbacks("keypressed", ...) end
function love.keyreleased(...) fire_callbacks("keyreleased", ...) end

function love.textinput(...)

end

function love.mousemoved(...)

end

function love.wheelmoved(...)

end

function love.mousepressed(...)

end

function love.mousereleased(...)

end

function love.gamepadpressed(...)

end

function love.gamepadreleased(...)

end





function input_module.getGamePointer()

end

function input_module.getMouse()

end

function input_module.listen(event, callback)
	if events[event] then
		
		table.insert(events[event], callback)


		return
	end
	error("input event ".. event.. " does not exist!")
end





local input = {}

local mousex, mousey = 0, 0

---
function input.setTransformedMouse(dx, dy)
	mousex = dx
	mousey = dy
end

---
function input.getTransformedMouse()
	return mousex, mousey
end

local function mod()
	local m = {}
	m.callbacks = {}
	setmetatable(m.callbacks, {})

	function m:connect(func)
		self.callbacks[#self.callbacks+1] = func
		return #self.callbacks
	end

	function m:disconnect(id)
		self.callbacks[id] = nil
	end

	function m:call(...)
		for _, func in pairs(self.callbacks) do
			func(...)
		end
	end
	return m
end
---
input.mousepressed = mod()
---
input.mousereleased = mod()
input.mousemoved = mod()
input.wheelmoved = mod()
input.textinput = mod()
input.keypressed = mod()
input.keyreleased = mod()

return input