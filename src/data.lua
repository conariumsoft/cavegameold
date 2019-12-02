--- Display information about game assets & their properties.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local items = require("src.items")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local rendering = require("src.rendering")

return function(args)
    love.window.setTitle("CAVEGAME DATA DUMP")
	love.window.setMode(
		1000, 600,
		{
			fullscreen = false,
			resizable = true,
			minwidth = 1280,
			minheight = 720,
			vsync = false,
		}
    )

    love.graphics.setNewFont(14)
    love.graphics.setLineWidth(1)

    local item_list = items:getList()
    local tile_list = tiles:getList()

    local showing_items = false

    local scroll = 0
    local scroll_amplifier = 20

    function love.wheelmoved(x, y)
        scroll = scroll + y
        print(scroll)
    end
    
    function love.keypressed(key)
        if key == "up" then
            scroll = scroll + 100
        end

        if key == "down" then
            scroll = scroll - 100
        end
    end

    function love.update(dt)

        rendering.update(dt)

        if scroll > 5 then scroll = 5 end


    end

    local function column(x)

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.line(x, -9999, x, 9999)
        love.graphics.setColor(1, 1, 1)
    end

    local function show_items()
        local idx = 0
        local dist = 48
        for name, data in pairs(item_list) do
            local y = idx*dist

            local display_name = data.displayname
            local stack = data.stack
            local rarity = data.rarity
            local id = data.id
            local color = data.color
            local scale = data.inWorldScale

            love.graphics.setColor(1, 1, 1)
            -- columns
            -- first column is texture
            rendering.drawItem(id, 8, y, 4, 4)
            column(48)
            
            -- second is id
            love.graphics.print("id: \n"..id, 55, y)
            column(90)
            -- next is internal name
            love.graphics.printf("name: \n"..name, 95, y, 200)
            column(290)
            -- displayname
            love.graphics.printf("displayname: \n"..display_name, 295, y, 200)
            column(495)
            -- stack
            love.graphics.printf("stack: \n"..stack, 500, y, 50)
            column(550)
            -- rarity
            love.graphics.printf("rarity: \n"..rarity, 555, y, 50)
            column(605)
            -- color
            love.graphics.printf("color: \n"..color[1]..","..color[2]..","..color[3], 610, y, 110)
            column(720)
            -- scale
            love.graphics.printf("scale: \n"..scale, 725, y, 50)
            column(775)
            
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.line(0, y+40, love.graphics.getWidth(), y+40)

            idx = idx + 1
        end
    end

    local function show_tiles()
        local idx = 0
        local dist = 48
        for name, data in pairs(tile_list) do
            local y = idx*dist

            local id = data.id
            local make_item = tostring(data.makeItem)
            local color = data.color
            local drop = tostring(data.drop)
            local tags = data.tags
            local texture = data.texture
            local collide = tostring(data.collide)
            local solid = tostring(data.solid)
            local hardness = data.hardness
            local absorb = data.absorb
            local light = data.light

            -- first column is texture
            rendering.drawTile(id, 8, y, 4, 4)
            column(48)
            
            -- second is id
            love.graphics.print("id:\n"..id, 55, y)
            column(90)
            -- next is internal name
            love.graphics.print("name:\n"..name, 95, y)
            column(270)
            -- collide
            love.graphics.print("collide:\n"..collide, 275, y)
            column(335)
            -- solid
            love.graphics.print("solid:\n"..solid, 340, y)
            column(395)
            -- drop
            love.graphics.print("drop:\n"..drop:sub(1, 16), 400, y)
            column(550)
            -- makes item
            love.graphics.print("makeitem:\n"..make_item, 555, y)
            column(640)
            -- hardness
            love.graphics.print("hard:\n"..hardness, 645, y)
            column(690)
            -- absorb
            love.graphics.print("absorb:\n"..absorb, 695, y)
            column(760)
            -- light
            if type(light) == "table" then
                love.graphics.print("light:\n{"..light[1]..","..light[2]..","..light[3].."}", 765, y)
            else
                love.graphics.print("light:\n"..light, 765, y)
            end
            column(870)
            -- color
            love.graphics.print("color:\n{"..color[1]..","..color[2]..","..color[3].."}", 875, y)
            column(1000)
            -- tags
            local tagstr = ""

            for idx, val in pairs(tags) do
                tagstr = tagstr ..val..", "
            end

            love.graphics.print("tags:\n"..tagstr.."", 1005, y)




            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.line(0, y+40, love.graphics.getWidth(), y+40)

            idx = idx + 1
        end
    end

    function love.draw()

        love.graphics.push()

        love.graphics.translate(0, (scroll*scroll_amplifier))
        
        

        if showing_items then
            show_items()
        else
            show_tiles()
        end


        love.graphics.pop()
        
    end

end

