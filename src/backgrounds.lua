--- Background tile API and registry.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local bgs = {}
local bgcollector = {}
local idreference = {}
local idinc = 0

do
	function bgcollector:getByID(tileid)
		assert(type(tileid=="number"), "BackgroundTileID must be a number!")
		
		
		if idreference[tileid] then
			return bgs[idreference[tileid]]
		else
			for name, data in pairs(bgs) do
				if data.id == tileid then
					idreference[tileid] = name
					return data
				end
			end
		end
		error("No bgtile with ID".. tileid.. "exists!", 2)
	end

	function bgcollector:getNumberOfTiles()
		return idinc
	end

	function bgcollector:getList()
		return bgs
	end

	local mt = {
		__index = function(t, k)

			if bgs[k] then return bgs[k] end
		end
	}

	setmetatable(bgcollector, mt)
end
----------------------------------


local function background(name, data)

	local default = {
		name = name,
		id = idinc,
		color = {1, 1, 1},
		drop = name.."_WALL",
		texture = "default",
		animation = nil,
		animationspeed = 4, -- animation frames/sec
		light = 0,
		absorb = 0,
	}

	local latestID = idinc
	if data.id~=nil then latestID = data.id end

	bgs[name] = {}
	for label, value in pairs(default) do
		bgs[name][label] = value
	end
	-- override default values
	for label, value in pairs(data) do
		bgs[name][label] = value
	end

	idinc = latestID + 1
end

background("AIR", {
	color = {1,1,1},
	absorb = 0,
	light = -1,
	id = 0,
})

background("LEAVES", {
	color = {0.2, 0.8, 0.2},
	texture = "leaves_opaque",
})

background("DIRT", {
	color = {0.45, 0.25, 0.1},
	texture = "soil",
})

background("MUD", {
	texture = "soil",
	color = {0.35, 0.15, 0.05}
})

background("CLAY", {
	color = {0.5, 0.25, 0.2},
	texture = "soil"
})

background("PSILOCYN", {
	texture = "soil",
	color = {0.3, 0.3, 0.6},
})

background("GLASS", {
	texture = "glass",
	color = {1, 1, 1},
	light = -1,
	absorb = 0,
})

background("PLANK", {
	texture = "plank",
	color = {0.7, 0.5, 0.2},
})

background("WOODEN_POLE", {
	texture = "pole",
	color = {0.7, 0.5, 0.2},
})

background("WEIRD", {
	texture = "weird",
	color = {0.6, 0.6, 0.6},
})

background("EYE1", {
	texture = "eye_1",
	color = {0.6, 0.6, 0.6},
})

background("EYE2", {
	texture = "eye_2",
	color = {0.6, 0.6, 0.6},
})

background("EYE3", {
	texture = "eye_3",
	color = {0.6, 0.6, 0.6},
})

background("EYE4", {
	texture = "eye_4",
	color = {0.6, 0.6, 0.6},
})

background("SAND_EYE1", {
	texture = "eye_1",
	color = {0.9, 0.7, 0.35},
})
background("SAND_EYE2", {
	texture = "eye_2",
	color = {0.9, 0.7, 0.35},
})
background("SAND_EYE3", {
	texture = "eye_3",
	color = {0.9, 0.7, 0.35},
})
background("SAND_EYE4", {
	texture = "eye_4",
	color = {0.9, 0.7, 0.35},
})

background("BROGE", {
	texture = "broge",
	color = {0.6, 0.6, 0.6},
})


background("WOOD_PANEL", {
	texture = "paneling",
	color = {0.7, 0.5, 0.2},
})

background("STONE", {
	color = {1, 1, 1},
	texture = "stone",
})

background("CHISELED_STONE", {
	color = {0.6, 0.6, 0.6},
	texture = "chiseled_stone",
})

background("SANDSTONE", {
	color = {0.9, 0.7, 0.35},
	texture = "stone",
})

background("CHISELED_SANDSTONE", {
	color = {0.9, 0.7, 0.35},
	texture = "chiseled_stone",
})

background("GRAY_BRICK", {
	color = {0.6, 0.6, 0.6},
	texture = "brick2",
})
background("YELLOW_BRICK", {
	color = {0.8, 0.7, 0.4},
	texture = "brick2",
})
background("RED_BRICK", {
	color = {0.9, 0.5, 0.5},
	texture = "brick2",
})

background("MUD_BRICK", {
	color = {0.4, 0.2, 0.1},
	texture = "brick2",
})

background("MOSSY_GRAY_BRICK", {
	texture = "mossybrick",
	color = {0.6, 0.6, 0.6}
})

background("DARK_BRICK", {
	color = {0.2, 0.2, 0.2},
	texture = "brick2",
})
background("WHITE_BRICK", {
	color = {1, 1, 1},
	texture = "brick2",
})

return bgcollector