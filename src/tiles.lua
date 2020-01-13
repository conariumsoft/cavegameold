--- Tile creation API and tile definition registry.
-- Read script for more details on tile API.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

--[[
	tile content API:

	table tilelist
	table tilemanager
	function newtile(string name, table data)
	function isSolid(int tileid) -> bool
	function adjacentToNonSolidTile(World w, int x, int y) -> bool
	
	tiledata = {
		string name,
		int id,
		bool makeItem = true,
		table[number, number, number] color = {1,1,1},
		string drop,
		table[] tags,
		string texture = "default",
		bool collide = true,
		bool solid = true,
		bool canexplode = true,
		number hardness = 2,
		number absorb = 0.15,
		number/table light = 1, -- setting to a table will enable RGB color
		table[string, ...] animation = nil,
		number animationspeed = 4,
		table[int,int,int,int] collisionBox = nil,
		function tileupdate(World world, int x, int y),
		function randomupdate(World world, int x, int y),
		function validplacement(World world, int x, int y), -> bool -- if false returns, the tile will break and/or not place
		function onplace(World world, int x, int y)
		function onbreak
		function customCollision(Entity entity, Vec2 separation, Vec2 normal)
		function playerInteract(Player player, int x, int y, int button)

		function layeredRender(int x, int y, var state, number dmg)
	}
	
]]
local jutils = require("src.jutils")

--- Gives the tileAPI access to the tiles module
-- @class table
-- @name tileAPI.tilemanager
local tilecollector = {}
local idreference = {}
--- List of tiles
-- @class table
-- @name tileAPI.tilelist
local tiles = {}
local idinc = 0

do
	--- Check if tile has a tag.
	-- @name tiles:tileHasTag
	-- @param tileid number id or tile table
	-- @param looktag string
	-- @return boolean
	function tilecollector:tileHasTag(tileid, looktag)
		
		local tiledata

		if type(tileid) == "number" then
			tiledata = tilecollector:getByID(tileid)
		else
			tiledata = tileid
		end

		for _, tag in pairs(tiledata.tags) do
			if tag == looktag then
				return true
			end
		end
		return false
	end

	--- Gets tile data table from tileid
	-- @name tiles:getByID
	function tilecollector:getByID(tileid)
		assert(type(tileid=="number"), "TileID must be a number!")

		if idreference[tileid] then
			return tiles[idreference[tileid]]
		else
			for name, data in pairs(tiles) do
				if data.id == tileid then

					idreference[tileid] = name
					return data
				end
			end
			error("No tile with ID".. tostring(tileid).. "exists!", 2)
		end
	end

	--- a
	-- @name tiles:getNumberOfTiles
	function tilecollector:getNumberOfTiles() return idinc end

	--- b
	-- @name tiles:getList
	function tilecollector:getList() return tiles end

	local mt = { __index = function(t, k) if tiles[k] then return tiles[k] end end }

	setmetatable(tilecollector, mt)
end

--- Tile constructor
-- @name tileAPI:newtile
local function tile(name, data)
	
	--- Tile data properties. There are more fields here, they should be collected somewhere else maybe.
	-- @class table
	-- @name tiledata
	-- @field name tile's internal name.
	-- @field color color table {r, g, b}
	-- @field drop string ID of the item to drop when broken.
	-- @field tags table of string tags.
	-- @field texture string.
	-- @field collide boolean
	-- @field solid boolean
	-- @field animation table or nil
	-- @field animationspeed i
	-- @field tileupdate update callback
	-- @field randomupdate random update callback
	-- @field validplacement callback
	-- @field onplace callback
	-- @field onbreak callback
	-- @field customrender callback
	-- @field layeredRender callback
	-- @field hardness number
	-- @field light number
	-- @field absorb number
	-- @field id the numeric id of the tile (automatically handled)
	local default = {
		name = name, 
		id = idinc,
		color = {1, 1, 1},
		drop = name.."_TILE",
		tags = {},
		texture = "default",
		collide = true,
		solid = true,
		animation = nil,
		animationspeed = 4, -- animation frames/sec
		tileupdate = nil,
		randomupdate = nil,
		validplacement = nil,
		onplace = nil,
		onbreak = nil,
		customrender = nil,
		hardness = 2,
		light = 0,
		canexplode = true,
		absorb = 0.15,
	}

	local latestID = idinc
	if data.id~=nil then latestID = data.id end

	tiles[name] = {}
	for label, value in pairs(default) do
		tiles[name][label] = value
	end
	-- override default values
	for label, value in pairs(data) do
		tiles[name][label] = value
	end

	idinc = latestID + 1
end

---
-- @name tileAPI:isSolid
local function isSolid(tileid)
	local data = tilecollector:getByID(tileid)
	return data.solid
end

--- a
-- @name tileAPI:adjacentToNonSolidTile
local function adjacentToNonSolidTile(world, x, y)
	for dx = -1, 1 do
		for dy = -1, 1 do
			if not isSolid(world:getTile(x+dx, y+dy)) then return true end	
		end
	end
	return false
end

local tileEnvironment = {
	newtile = tile,
	tilelist = tiles,
	tilemanager = tilecollector,
	isSolid = isSolid,
	adjacentToNonSolidTile = adjacentToNonSolidTile,
}
setmetatable(tileEnvironment, {__index = _G})

local files = love.filesystem.getDirectoryItems("data/tiles/")
--print("loading tile files")
for k, file in ipairs(files) do
	--print(k, file)

	local d, errmsg = love.filesystem.load("data/tiles/"..file)
	if errmsg then print(errmsg) end
	setfenv(d, tileEnvironment)
	d()
end

return tilecollector