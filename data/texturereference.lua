local config = require("config")
local tilesheet = love.graphics.newImage("assets/tilesheet.png")

local function tileQuad(qx, qy)
	return love.graphics.newQuad(qx*config.TILE_SIZE, qy*config.TILE_SIZE, config.TILE_SIZE, config.TILE_SIZE, tilesheet:getDimensions())
end

local references = {
	tiles = { 
		default 		= tileQuad(0, 0),
		stone 			= tileQuad(1, 0),
		plank 			= tileQuad(2, 0),
		soil			= tileQuad(3, 0),
		mossybrick 		= tileQuad(4, 0),
		paneling 		= tileQuad(5, 0),
		leaves_opaque 	= tileQuad(6, 0),
		leaves	 		= tileQuad(7, 0),
		alchemy_lab_1_1 = tileQuad(8, 0),
		alchemy_lab_2_1 = tileQuad(9, 0),
		alchemy_lab_3_1 = tileQuad(10, 0),
		refinery_1_1 	= tileQuad(11,0),
		refinery_2_1 	= tileQuad(12, 0),
		refinery_3_1 	= tileQuad(13, 0),

		gas_blank = tileQuad(10, 4),
		--
		brick = tileQuad(0, 1),
		ore = tileQuad(1, 1),
		tnt = tileQuad(2, 1),
		root_left = tileQuad(3, 1),
		root = tileQuad(4, 1),
		root_right = tileQuad(5, 1),
		hellrock = tileQuad(6, 1),
		glass = tileQuad(7, 1),
		alchemy_lab_1_2 = tileQuad(8, 1),
		alchemy_lab_2_2 = tileQuad(9, 1),
		alchemy_lab_3_2 = tileQuad(10, 1),
		refinery_1_2 = tileQuad(11, 1),
		refinery_2_2 = tileQuad(12, 1),
		refinery_3_2 = tileQuad(13, 1),
		--
		
		log = tileQuad(0, 2),
		platform = tileQuad(1, 2),
		vine = tileQuad(2, 2),
		rope = tileQuad(3, 2),
		sapling = tileQuad(4, 2),
		blue_flower = tileQuad(5, 2),
		purple_mushroom = tileQuad(6, 2),
		red_mushroom = tileQuad(7, 2),
		campfire_1_1 = tileQuad(8, 2),
		campfire_2_1 = tileQuad(9, 2),
		furnace_1_1 = tileQuad(10, 2),
		furnace_2_1 = tileQuad(11, 2),
		open_door_1_1 = tileQuad(12, 2),
		open_door_2_1 = tileQuad(13, 2),
		door_1_1 = tileQuad(14, 2),
		--
		sandstone = tileQuad(0, 3),
		supported_platform = tileQuad(1, 3),
		
		brick2 = tileQuad(2, 3),

		weird = tileQuad(3, 3),
		pole = tileQuad(4, 3),
		chiseled_stone = tileQuad(5, 3),

		broge = tileQuad(1, 4),

		eye_1 = tileQuad(2, 4),
		eye_2 = tileQuad(3, 4),
		eye_3 = tileQuad(2, 5),
		eye_4 = tileQuad(3, 5),

		pot = tileQuad(7, 3),

		cobweb = tileQuad(6, 3),

		campfire_1_2 = tileQuad(8, 3),
		campfire_2_2 = tileQuad(9, 3),
		furnace_1_2 = tileQuad(10, 3),
		furnace_2_2 = tileQuad(11, 3),
		open_door_1_2 = tileQuad(12, 3),
		open_door_2_2 = tileQuad(13, 3),
		door_1_2 = tileQuad(14, 3),

		

		workbench_1_1 = tileQuad(10, 4),
		workbench_2_1 = tileQuad(11, 4),
		open_door_1_3 = tileQuad(12, 4),
		open_door_2_3 = tileQuad(13, 4),
		door_1_3 = tileQuad(14, 4),
		--
		
		overgrowth1 = tileQuad(8, 5),
		overgrowth2 = tileQuad(9, 5),
		overgrowth3 = tileQuad(10, 5),
		torch_a = tileQuad(11, 5),
		torch_b = tileQuad(12, 5),
		torch_c = tileQuad(13, 5),
		torch_d = tileQuad(14, 5),

		cactus = tileQuad(0, 6),
		cactus_flowering = tileQuad(1, 6),
		gas_patch = tileQuad(8, 6),
		gas_corner = tileQuad(9, 6),

		chest_1_1 = tileQuad(10, 6),
		chest_2_1 = tileQuad(11, 6),
		mechanarium_1_1 = tileQuad(12, 6),
		mechanarium_2_1 = tileQuad(13, 6),
		mechanarium_3_1 = tileQuad(14, 6),

		wire = tileQuad(1, 7),
		wire_base = tileQuad(2, 7),
		switch = tileQuad(2, 6),
		
		anvil_1_1 = tileQuad(8, 7),
		anvil_2_1 = tileQuad(9, 7),
		chest_1_2 = tileQuad(10, 7),
		chest_2_2 = tileQuad(11, 7),
		mechanarium_1_2 = tileQuad(12, 7),
		mechanarium_2_2 = tileQuad(13, 7),
		mechanarium_3_2 = tileQuad(14, 7),

		--
		blank = tileQuad(15, 7)
	},
	liquids = {
		[1] = tileQuad(15, 0),
		[2] = tileQuad(15, 1),
		[3] = tileQuad(15, 2),
		[4] = tileQuad(15, 3),
		[5] = tileQuad(15, 4),
		[6] = tileQuad(15, 5),
		[7] = tileQuad(15, 6),
		[8] = tileQuad(15, 7),
	}
}

return references