--- Common GUI utilities.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local jui = require("src.jui")
local jutils = require("src.jutils")

love.graphics.setDefaultFilter("nearest", "nearest")

local fonts = {
    default     = love.graphics.newFont(12),
    font_6      = love.graphics.newFont("assets/fonts/adds.ttf", 6 ),
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



return gui_utils