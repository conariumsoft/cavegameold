local function jbit(t)
	local ret = 0
	local bitfieldlen = #t

	for i = bitfieldlen, 1, -1 do
		local exponent = 2^(i-1)
		local bitval = (t[i] == true) and 1 or 0

		ret = ret + (bitval*exponent)
	end
	return ret
end

local function obit(num, bitindex)
	return bit.band(bit.rshift(num, bitindex), 1) == 1 and true or false
end
