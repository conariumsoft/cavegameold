--- joshuu's utilities v2.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

-- characters that will be removed by jutils.string.sanitize
local illegal_characters = {
    "\"", "%<", "%>", "%+", "%-", "%*",  "%%", "%$", "#", "@", "!", "{", "}", "|", "\\",
    "/", ";", ":", "'", "`", "~", "%(", "%)", "%&", "%^"
}

local jutils = {}


jutils.misc = {} do

    --- Primitive type checker. Throws an error if there is a type mismatch.
    -- @param argument the argument to be checked
    -- @param correctType string - poopee
    function jutils.misc.check(argument, correctType)
        if type(argument) ~= correctType then
            error("type mismatch: expected "..correctType..", but got "..type(argument).." instead.", 2)
        end
    end

    --- Recursively prints the contents of a table.
    -- Output takes the form of
    -- {
    --      key = value,
    --      key2 = value2,
    --      ...
    -- }
    -- @param t table to be inspected.
    -- @param recursions dont fill this argument.
    function jutils.misc.inspect(t, recursions)
        recursions = recursions or 0

        local tab = ""

        for i = 1, recursions do
            tab = tab .. "\t"
        end

        print(tab.."{ -- size "..#t)

        for index, value in pairs(t) do
            
            if type(value) == "table" then
                io.write(tab .."\t".. index .." =")
                jutils.misc.inspect(value, recursions+1)
            else
                print(tab .."\t".. index.." = "..value..",")
            end
        end

        print(tab.."}")
    end

    --- Prints the contents of a table, in order, without keys, and without recursion.
    -- Output takes the form of { a, b, c, d, ...}
    -- @param t table to inspect
    function jutils.misc.inspectArray(t)
        io.write("{")

        for index, value in ipairs(t) do
            io.write(value..", ")
        end
        io.write("}\n")
    end

end

jutils.event = {} do

    --- Returns a new EventInstance.
    -- @return EventInstance
    function jutils.event.new()

        local m = {}
        m._callbacks = {}
        --- Connects a callback function to the event listener.
        -- @name EventInstance:connect
        -- @param func
        -- @return callbackID the ID of that callback. Used for disconnecting the callback.
        function m:connect(func)
            local id = #self._callbacks+1
            self._callbacks[id] = func
            return id
        end

        --- Disconnects a callback from the event.
        -- @name EventInstance:disconnect
        -- @param id the callback's ID
        function m:disconnect(id)
            self._callbacks[id] = nil
        end

        --- Disconnects all callbacks from the event.
        -- @name EventInstance:disconnectAll
        function m:disconnectAll()
            for index, _ in pairs(self._callbacks) do
                self._callbacks[index] = nil
            end
        end

        --- Calls all callbacks connected to the event.
        -- @name EventInstance:call
        -- @param ... arguments to pass to the callbacks
        function m:call(...)
            for _, func in pairs(self._callbacks) do
                func(...)
            end
        end
        return m
    end
end

jutils.math = {} do

    --- Linear interpolation between two numbers.
    -- Alpha is the percentage between start and finish.
    -- @param start
    -- @param finish
    -- @param alpha 0 - 1
    -- @return number
    function jutils.math.lerp(start, finish, alpha)

        jutils.misc.check(start, "number")
        jutils.misc.check(finish, "number")
        jutils.misc.check(alpha, "number")
        
        local shrek = (1-alpha)*start + alpha*finish
        --print(start, finish, alpha, shrek)
        return shrek
    end

    --- Round a number n to the nearest multiple.
    -- @param n input number
    -- @param mult
    -- @return number
    function jutils.math.multiple(n, mult)
        mult = mult or 10

        jutils.misc.check(n, "number")
        jutils.misc.check(mult, "number")

        return jutils.math.round(n/mult)*mult
    end

    --- Round a number n to x decimal places.
    -- @param n 
    -- @param dplaces
    -- @return number
    function jutils.math.round(n, dplaces)
        dplaces = 10^(dplaces or 0)

        jutils.misc.check(n, "number")
        jutils.misc.check(dplaces, "number")

        return math.floor(n*dplaces+0.5)/dplaces
    end

    --- Returns the sign of the given number.
    -- Positive numbers return 1, negative numbers return -1. 0 will return 0.
    -- @param n
    -- @return number
    function jutils.math.sign(n)
        return n>0 and 1 or n < 0 and -1 or 0
    end

    --- Returns a number clamped between two values.
    -- high >= n >= low.
    -- @param low
    -- @param n
    -- @param high
    -- @return number
    function jutils.math.clamp(low, n, high)

        jutils.misc.check(low, "number")
        jutils.misc.check(n, "number")
        jutils.misc.check(high, "number")

        return math.min(math.max(low, n), high)
    end

    function jutils.math.noise(x, y, z, seed)

    end



end
jutils.table = {} do

    --- Performs an operation on each key-pair value in a table: func(index, value)
    -- @param t 
    -- @param func the function to perform operations. should take an index and value argument.
    function jutils.table.foreach(t, func)
        jutils.misc.check(t, "table")
        jutils.misc.check(func, "function")
        
        for index, value in pairs(t) do
            func(index, value)
        end
    end

    --- Recursively copy a table, as well as any associated metatables.
    -- @param orig the original table
    -- @return table
    function jutils.table.copy(orig)
        local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[jutils.table.copy(orig_key)] = jutils.table.copy(orig_value)
			end
			setmetatable(copy, jutils.table.copy(getmetatable(orig)))
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
    end

    --- Fills a table from index [1] to [size] with the construction.
    -- @param construction data to fill the table with.
    -- @param size the number of indices to fill
    -- @return table
    function jutils.table.constructArray(construction, size)
        jutils.misc.check(size, "number")
        local t = {}
        for i = 1, size do
            t[i] = jutils.table.copy(construction)
        end
        return t
    end

    -- Check if a table contains a value
    -- @param t table to check
    -- @param val value to find
    -- @return bool
    function jutils.table.contains(t, val)
        for idx, value in pairs(t) do
            if value == val then return true end
        end
        return false
    end

    --- Combines an arbitrary amount of tables, based on priority. The first table in gets to fill values first,
    -- and cannot have those values overridden by subsequent tables.
    -- @param ... any number of tables
    -- @return table
    function jutils.table.combine(...)
        local tabs = {...}
        local finalT = {}
        for idx, t in ipairs(tabs) do
            for index, value in pairs(t) do
                if finalT[index] == nil then
                    finalT[index] = value
                end
            end
        end
        return finalT
    end
end

jutils.string = {} do

    --- Splits a given string by a divider. Returned as a table.
    -- @param str input string
    -- @param divider the character to look for when splitting the string. for example, use " " if splitting a sentence.
    -- @return table
    function jutils.string.explode(str, divider)
        jutils.misc.check(str, "string")
        jutils.misc.check(divider, "string")
        local o = {}
		while true do
			local pos1, pos2 = str:find(divider)
			if not pos1 then
				o[#o+1] = str
				break
			end
			o[#o+1], str = str:sub(1, pos1-1), str:sub(pos2+1)
		end
		return o
    end

    ---
    function jutils.string.fromTable(strTable)
        local endstr = ""
        for idx, val in ipairs(strTable) do
            endstr = endstr .. val
            if not (idx >= #strTable) then
                endstr = endstr .. " "
            end
        end
        return endstr
    end

    ---
    function jutils.string.sanitize(str, replacement)
        for _, char in pairs(illegal_characters) do
            str = str:gsub(char, replacement)
        end
        return str
    end

end

jutils.color = {} do

    local function colorCheck(r, g, b, a)
        jutils.misc.check(r, "number")
        jutils.misc.check(g, "number")
        jutils.misc.check(b, "number")
        jutils.misc.check(a, "number")
    end

    --- Moves color values from 0-255 range into 0-1 range. Alpha defaults to 255 if not provided.
    -- @param r (red) 0-255
    -- @param g (green) 0-255
    -- @param b (blue) 0-255
    -- @param a [optional] = 255, (alpha) 0-255
    -- @return table {r, g, b, a = 1}
    function jutils.color.fromIntRGB(r, g, b, a)
        a = a or 255
        colorCheck(r, g, b, a)
        return {r/255, g/255, b/255, a/255}
    end

    --- Moves color values from HSL+A space into RGB+A space. Alpha is optional.
    -- @param h
    -- @param s
    -- @param l
    -- @param a [optional] = 1
    -- @return table {r, g, b, a}
    function jutils.color.fromHSL(h, s, l, a)
        a = a or 1
        colorCheck(h, s, l, a)
        if s == 0 then return l,l,l end
		h, s, l = h*6, s, l
		local c = (1-math.abs(2*l-1))*s
		local x = (1-math.abs(h%2-1))*c
		local m,r,g,b = (l-.5*c), 0,0,0
		if h < 1     then r,g,b = c,x,0
		elseif h < 2 then r,g,b = x,c,0
		elseif h < 3 then r,g,b = 0,c,x
		elseif h < 4 then r,g,b = 0,x,c
		elseif h < 5 then r,g,b = x,0,c
		else              r,g,b = c,0,x
		end
		local r, g, b = r+m, g+m, b+m
		return {r, g, b, (a or 1)}
    end

    --- Converts a hexadecimal color string into an RGB table.
    -- @param hexcode the hex color code string
    -- @param a [optional] = 1
    -- @return table {r, g, b, a}
    function jutils.color.fromHex(hexcode, a)
        a = a or 1
        jutils.misc.check(hexcode, "string")
        jutils.misc.check(a, "number")

        local hex = hexcode:gsub("#","")

		local r, g, b
		if hex:len() == 3 then
		  r, g, b = (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255
		else
		  r, g, b = tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
		end
	
		return {r, g, b, (a or 1)}
    end

    --- Converts a color sequence into integer RGB values (0-255).
    -- @param r (blue) 0-1
    -- @param g (green) 0-1
    -- @param b (blue) 0-1
    -- @param a [optional] = 1
    -- @return table {r, g, b, a}
    function jutils.color.toIntRGB(r, g, b, a)
        a = a or 1

        colorCheck(r, g, b, a)
        return {r*255, g*255, b*255, a*255}
    end

    --- Adds the components of two color tables together.
    -- @param c1 
    -- @param c2
    -- @return table {r, g, b, a}
    function jutils.color.add(c1, c2)
        local r = c1[1] + c2[1]
        local g = c1[2] + c2[2]
        local b = c1[3] + c2[3]

        --local a1, a2 = 1

        --if c1[4] ~= nil then a1 = c1[4] end
       -- if c2[4] ~= nil then a2 = c2[4] end

       -- local a = a1 + a2

        return {r, g, b}
    end

    -- Multiplies the components of two color tables together.
    function jutils.color.multiply(c1, c2)
        local r = c1[1] * c2[1]
        local g = c1[2] * c2[2]
        local b = c1[3] * c2[3]

       -- local a1, a2 = 1

       -- if c1[4] ~= nil then a1 = c1[4] end
       -- if c2[4] == nil then a2 = c2[4] end

       -- local a = a1 * a2

        return {r, g, b}
    end

    -- Linear interpolation between two color tables.
    function jutils.color.lerp(c1, c2, alpha)

        local r = jutils.math.lerp(c1[1], c2[1], alpha)
        local g = jutils.math.lerp(c1[2], c2[2], alpha)
        local b = jutils.math.lerp(c1[3], c2[3], alpha)
        
        --local a1, a2 = 1

        --if c1[4] ~= nil then a1 = c1[4] end
        --if c2[4] == nil then a2 = c2[4] end

        --local a = jutils.math.lerp(a1, a2, alpha)

        return {r, g, b}
    end


end
jutils.vec2 = {} do

    jutils.vec2.__index = jutils.vec2

    --- Constructs a new vec2 instance.
    -- @param x
    -- @param y
    function jutils.vec2.new(x, y)
        local self = setmetatable({}, jutils.vec2)
        self.x = (x and x or 0)
        self.y = (y and y or 0)
        return self
    end

    --- Checks if two vectors are equal after flooring the coordinates of both vectors.
    -- This means the equality check is not precise, but rather, if the two vectors are close enough to each other.
    -- @usage vec2:equals(vec2)
    -- @usage jutils.vec2.equals(vec2, vec2)
    -- @param vecA
    -- @param vecB
    -- @return boolean
    function jutils.vec2.equals(vecA, vecB)
        return (math.floor(vecA.x) == math.floor(vecB.x) and math.floor(vecA.y) == math.floor(vecB.y))
    end

    --- Checks if two vectors are precisely equal.
    -- @usage jutils.vec2.equalsPrecise(vec2, vec2)
    -- @usage vec2:equalsPrecise(vec2)
    -- @param vecA
    -- @param vecB
    -- @return boolean
    function jutils.vec2.equalsPrecise(vecA, vecB)
        return (vecA.x == vecB.y and vecA.y == vecB.y)
    end

    --- asscock
    -- @name vec2 + vec2
    function jutils.vec2.__add(vec1, vec2)
        return jutils.vec2.new(vec1.x+vec2.x, vec1.y+vec2.y)
    end

    --- Scalar multiplication.
    -- @name vec2 * number
    -- @field vec2 * number
    -- @return vec2
    function jutils.vec2.__mul(vector, scalar)
        return jutils.vec2.new(vector.x*scalar, vector.y*scalar)
    end

    --- b
    -- @name vec2 - vec2
    function jutils.vec2.__sub(vec1, vec2)
        return jutils.vec2.new(vec1.x-vec2.x, vec1.y-vec2.y)
    end

    --- Linear interpolation between two vectors.
    -- @usage jutils.vec2.lerp(vec2, vec2, alpha)
    -- @usage vec2:lerp(vec2, alpha)
    -- @param vecA
    -- @param vecB
    function jutils.vec2.lerp(vec1, vec2, alpha)
        local x = jutils.math.lerp(vec1.x, vec2.x, alpha)
        local y = jutils.math.lerp(vec1.y, vec2.y, alpha)

        return jutils.vec2.new(x, y)
    end

    --- Returns the vector's magnitude.
    -- @usage jutils.vec2.magnitude(vector)
    -- @usage vec2:magnitude()
    -- @param vector
    function jutils.vec2.magnitude(vector)
        return (vector.x^2 + vector.y^2)^0.5
    end

    --- Returns the distance between two vectors.
    -- @usage jutils.vec2.distance(vec1, vec2)
    -- @usage vec2:distance(vec)
    -- @param vec1
    -- @param vec2
    -- @return vec2
    function jutils.vec2.distance(vec1, vec2)
        local x1 = vec1.x
        local x2 = vec2.x
        local y1 = vec1.y
        local y2 = vec2.y

        return ((x2-x1)^2 + (y2-y1)^2) ^ 0.5
    end

    --- Returns the unit of the vector (distance = 1).
    -- @usage jutils.vec2.unitvec(vec2)
    -- @usage vec2:unitvec()
    -- @param vector
    -- @return vec2
    function jutils.vec2.unitvec(vector)
        local magnitude = vector:magnitude()

        return jutils.vec2.new(vector.x / magnitude, vector.y / magnitude)
    end

    --- Unimplemented

    function jutils.vec2.copy(vector)
        return jutils.vec2.new(vector.x, vector.y)
    end

    function jutils.vec2.angle(vector)
        error("NOT IMPLEMENTED")
    end

    --- Returns the angle between two vectors.
    -- @param vec1
    -- @param vec2
    -- @usage jutils.vec2.angleBetween(vec1, vec2)
    -- @usage vec2:angleBetween(vec2)
    -- @return number
    function jutils.vec2.angleBetween(vec1, vec2)
        return math.atan2(vec2.y - vec1.y, vec2.x - vec1.x) * 180 / math.pi
    end
    
    --- Returns the dot product of two vectors.
    -- @see https://www.mathsisfun.com/algebra/vectors-dot-product.html
    function jutils.vec2.dotProduct(vec1, vec2)
        return (vec1.x * vec2.x) + (vec1.y * vec2.y)
    end
end
jutils.line = {} do

    -- determines of segment l1 intersects segment l2
    function jutils.line.intersects(p1l1, p2l1, p1l2, p2l2)

    end

end
jutils.rect = {} do

end

jutils.object = {} do

    local obj = {}

    obj.__index = obj
    obj.types = {"Object"}


    --- Instance creation callback, User defines class:init(...) and jutils calls it when class:new(...) is called.
    -- @usage function myClass:init(arg) self.property = arg end
    -- @name jutils.object:init
    -- @see jutils.object:new
    -- @see jutils.object:subclass
    function obj:init(...)

    end

    --- Returns a new instance of the class. Passes arguments to obj:init().
    -- @see jutils.object:init
    -- @see jutils.object:subclass
    -- @usage local myInst = myClass:new(...)
    -- @name jutils.object:new
    function obj:new(...)
        local inst = setmetatable({}, {__index = self})
        inst:init(...)
        return inst
    end

    --- Creates a subclass object that can be extended.
    -- Used for basic OOP.
    -- @usage local myClass = jutils.obj:subclass("myclass")
    -- @name jutils.object:subclass
    -- @param classname
    -- @return object
    -- @see jutils.object:init
    -- @see jutils.object:new
    function obj:subclass(classname)
        local t = setmetatable({}, {__index = self})
        t.__index = t
        t.classname = classname
        t.types = jutils.table.copy(self.types)
        table.insert(t.types, classname)
        t.super = self
        return t
    end

    --- Returns true if object is of the specified type.
    -- @name jutils.object:isA
    -- @return boolean
    function obj:isA(objtype)
        if jutils.table.contains(self.types, objtype) then
            return true
        end
        return false
    end

    function obj:__tostring()
        print(self.classname)
    end

    jutils.object = obj

end

return jutils