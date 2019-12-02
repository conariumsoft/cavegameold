--- User input utilities and weird workarounds.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
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