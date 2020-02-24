--- API and Registry for crafting recipe definitions.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local recipes = {
}

local function recipeConstructor(station, r, p)

	if station == nil then
		station = "none"
	end
	if not recipes[station] then recipes[station] = {} end
	
	table.insert(recipes[station], {reactants = r, products = p})
end

local env = {
	recipe = recipeConstructor,
}
setmetatable(env, {__index = _G})

local files = love.filesystem.getDirectoryItems("data/recipes/")

--print("loading recipe scripts")
for k, file in ipairs(files) do  
	--print("\tfile ".. file)

	local d, errmsg = love.filesystem.load("data/recipes/"..file)
	if errmsg then print(errmsg) end
	setfenv(d, env)
	d()
end

for station, list in pairs(recipes) do
	for _, recipe in pairs(list) do
		local reactants = recipe.reactants
		local products = recipe.products

		assert(reactants ~= nil, "reactants are nil")
		assert(products ~= nil, "products are nil")

		for index, reactant in pairs(reactants) do
			local item = reactant[1]
			local amount = reactant[2]

			assert(item ~= nil)
			assert(amount ~= nil)
		end

		for index, product in pairs(products) do
			local item = product[1]
			local amount = product[2]

			assert(item ~= nil)
			assert(amount ~= nil)
		end
	end
end


return recipes