--- Common GUI utilities.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local jui = require("src.jui")
local jutils = require("src.jutils")

love.graphics.setDefaultFilter("nearest", "nearest")

local fonts = {
    default     = love.graphics.newFont(12),
    font_8      = love.graphics.newFont("assets/fonts/adds.ttf", 8 ),
    font_12     = love.graphics.newFont("assets/fonts/adds.ttf", 12),
    font_14     = love.graphics.newFont("assets/fonts/adds.ttf", 14),
    font_16     = love.graphics.newFont("assets/fonts/adds.ttf", 16),
    font_20     = love.graphics.newFont("assets/fonts/adds.ttf", 20),
    font_24     = love.graphics.newFont("assets/fonts/adds.ttf", 24),
    font_30     = love.graphics.newFont("assets/fonts/adds.ttf", 30),
    font_40     = love.graphics.newFont("assets/fonts/adds.ttf", 40)
}

local core_button_style = {
    image = love.graphics.newImage("assets/ui/button.png"),
    sourceWidth = 16,
    sourceHeight = 16,
    cornerWidth = 7,
    cornerHeight = 7,
    imageScale = 2,
}

local core_text_style = {
    font = fonts.font_16,
    textColor = jutils.color.fromHex("#FFFFFF"),
    textXAlign = "center",
    textYAlign = "center",
}

local gui_utils = {
    fonts = fonts,
    core_button_style = core_button_style,
    core_text_style = core_text_style
}

function gui_utils.make_button(textstyle, style, clickCallback)

    style = style or {}
    local box = jui.nineslice:new(jutils.table.combine(style, core_button_style))
    local text = jui.text:new(jutils.table.combine(textstyle, core_text_style))
    return {
        box,
        {
            text = {
                text
            },
            click = {
                jui.mouseListener:new({
                    mouseEnter = function()
                        text.textColor = {0.7, 0.7, 0.7}
                        box.color = {0.5, 0.5, 0.5}
                    end,
                    mouseExit = function()
                        
                        text.textColor = {1, 1, 1}
                        box.color = {1, 1, 1}
                    end,

                    mouseButtonUp = clickCallback
                })
            }
        }
    }

end


return gui_utils