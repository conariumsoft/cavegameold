--- joshuu's console v2. Used for running commands while in-game.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
love.graphics.setDefaultFilter("nearest", "nearest")
local jutils = require("src.jutils")
local jui = require("src.jui")

local textinput = jui.textinput

local styles = {
    window  = {
        scaleSize = jutils.vec2.new(0.5, 1),
        pixelSize = jutils.vec2.new(-50, -50),
        pixelPosition = jutils.vec2.new(25, 25),
        scalePosition = jutils.vec2.new(0.5, 0),
        backgroundColor = {0, 0, 0, 0},
        borderColor = {0.5, 0.5, 0.5, 0.75},
        borderWidth = 2,
    },
    topbar = {
        scaleSize = jutils.vec2.new(1, 0),
        pixelSize = jutils.vec2.new(0, 16),
        pixelPosition = jutils.vec2.new(0, 0),
        backgroundColor = {0.25, 0.25, 0.25},
        borderEnabled = false,
    },
    content = {
        scaleSize = jutils.vec2.new(1, 1),
        pixelSize = jutils.vec2.new(0, -16),
        pixelPosition = jutils.vec2.new(0, 16),
        backgroundColor = {0.85, 0.85, 0.85, 0.6},
        borderEnabled = false,
    },
    titleText = {
        text = " jConsole",
        textColor = {0, 0, 0},
        font = love.graphics.newFont(12),
        textYAlign = "top",
    },
    infoText = {
        text = "Waiting on data...",
        textColor = {0.2, 0.2, 0.2},
        font = love.graphics.newFont(12),
        textYAlign = "bottom",
    },
    messageBox = {
        backgroundColor = {0, 0, 0, 0},
        pixelSize = jutils.vec2.new(0, -20),
        scaleSize = jutils.vec2.new(1, 1),
        borderEnabled = false,
    },
    inputBox = {
        pixelSize = jutils.vec2.new(0, 20),
        scaleSize = jutils.vec2.new(1, 0),
        scalePosition = jutils.vec2.new(0, 1),
        pixelPosition = jutils.vec2.new(0, -20),
        backgroundColor = {0.2, 0.2, 0.2},
        borderEnabled = false,
        
    },
    inputText = {
        textColor = {0.8, 0.8, 0.8},
        keepHistory = true,
    },
    
}
local titleTextObject = jui.text:new(styles.titleText)
local messageBoxChildren = {}

local inputTextObject = textinput:new(styles.inputText)
local inputBoxObject = jui.rectangle:new(styles.inputBox, {
    text = inputTextObject
})

local console = jui.scene:new({}, {
    window = jui.rectangle:new(styles.window, {
        topbar = jui.rectangle:new(styles.topbar, {
            title = titleTextObject,
        }),
        content = jui.rectangle:new(styles.content, {
            messages = jui.rectangle:new(styles.messageBox, {
                list = jui.list:new({}, messageBoxChildren)
            }),
            inputbox = inputBoxObject
        })
    })
})

local function newMessage(text, textColor)
    local boxStyle = {
        borderEnabled = false,
        backgroundColor = {0, 0, 0, 0},
        scaleSize = jutils.vec2.new(1, 0),
        pixelSize = jutils.vec2.new(0, 18),
    }
    local textStyle = {
        text = text,
        textColor = textColor
    }

    local box = jui.rectangle:new(boxStyle,
    {
        text = jui.text:new(textStyle)
    })

    table.insert(messageBoxChildren, box)

end


newMessage("Initialized", {0, 0, 0})


local jcon = {}

function jcon.message(message, color)
    newMessage(message, color)
end

function jcon.keypressed(key)
    if key == "tab" then
        jcon.open = not jcon.open
    else
        if jcon.open then
            inputTextObject:keypressed(key)
        end
    end
end

function jcon.textinput(t)
    if jcon.open then
        inputTextObject:textinput(t)
    end
end

jcon.commandListener = jutils.event:new()
jcon.open = false

function inputTextObject:onInput(input)
    if #input > 0 then
        input = string.sub(input, 1, 64) -- arbitrary limit for poopy...
        newMessage(">"..input, {0.4, 0.4, 0.4})
        input = string.lower(input)
        local split = jutils.string.explode(input, " ")
        if split then
            local args = {}
            for i = 2, #split do
                args[i-1] = split[i]
            end
            --print(split[1], args)
            jcon.commandListener:call(split[1], args)
        end
    end
end

local canfit = 0

function jcon:update(dt)
    if self.open then

        titleTextObject.text = " fps: "..love.timer.getFPS()..", luavm: "..jutils.math.round(collectgarbage("count")/1000, 2).."kb"
        console:update(dt)

        local messagebox = console:find("messages")

        canfit = math.floor(messagebox.absoluteSize.y/18)

        local list = console:find("list")

        if #list.children > canfit then
            list.children[1] = nil
            table.remove(list.children, 1)
        end

        print(canfit)
    end
end

function jcon:draw()
    if self.open then
        console:draw()
    end
end

return jcon