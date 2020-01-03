--- joshuu's user interface module v2.
-- Built for use with LOVE 2D framework, but should be fairly straightforward to port to another if desired.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
--[[
    joshuu's User Interface utility V2
    
    built for use with LOVE 2D framework, but should
    be fairly straightforward to port to another if 
    desired.

    JUI requires jutils to run.

    jui api:

        rootObject <internal>
            properties:
                string id = "GuiObject"
                callback onUpdate()
                vec2 absoluteSize <internal>
                vec2 absolutePosition <internal>

        rectangle
            properties:
                number borderWidth
                color borderColor
                vec2 pixelSize
                vec2 scaleSize
                vec2 pixelPosition
                vec2 scalePosition
                bool borderEnabled
                number bevel
                bool enabled
                color backgroundColor

        text
            properties:
                string text
                Love2DFont font
                color textColor
                enum textXAlign
                enum textYAlign

        image
            properties:
                Love2DImage image
                Love2DQuad quad
                color color
                enum scalingMode
                number rotation
                vec2 offset

        nineSlice
            properties:
                sourceWidth
                sourceHeight
                cornerWidth
                cornerHeight
                image
                imageScale


        slider


        mouseListener
            properties:
                number mouseButton (1 = lmb, 2 = rmb, 3 = mmb)
                bool mouseInside
                bool mouseDown
                bool mousePressed
                function mouseEnter
                function mouseExit
                function mouseButtonUp
                function mouseButtonDown

                bool _mouseEntranceDebounce = false
        list

        grid
            properties
                vec2 cellScaleSize
                vec2 cellPixelSize
                vec2 cellPadding

]]


local jutils = require("src.jutils") -- make sure to update this if you drop these libraries in a "lib"
-- folder or whatever
local love2dDefaultFont = love.graphics.getFont()
------------------------------------

-- TODO: implement rectangle origin
-- TODO: implement scrolling rectangle

local rootObj = jutils.object:subclass("juiRoot")

function rootObj:init(properties, children)
    self.id = "GuiObject"
    self.onUpdate = function(self, dt) end
    for prop, value in pairs(properties) do
        self[prop] = value
    end
    self.absoluteSize = jutils.vec2.new(0, 0)
    self.absolutePosition = jutils.vec2.new(0, 0)
    self.children = children
end

local function recursiveSearch(object, childname)
    for idx, child in pairs(object.children) do
        if idx == childname then return child end
        if child.children then
            local res = recursiveSearch(child, childname)

            if res then return res end
        end
    end
    return nil
end

function rootObj:find(childname)
    return recursiveSearch(self, childname)
end

function rootObj:update(dt, parent)
    local parentAbsSize = parent.absoluteSize
    local parentAbsPos =  parent.absolutePosition

    local xSize = self.pixelSize.x + (parentAbsSize.x * self.scaleSize.x)
    local ySize = self.pixelSize.y + (parentAbsSize.y * self.scaleSize.y)

    local xPos = parentAbsPos.x + self.pixelPosition.x + (parentAbsSize.x * self.scalePosition.x)
    local yPos = parentAbsPos.y + self.pixelPosition.y + (parentAbsSize.y * self.scalePosition.y)

    self.absoluteSize = jutils.vec2.new(xSize, ySize)

    self.absolutePosition = jutils.vec2.new(xPos, yPos)

    if self.onUpdate then
        self:onUpdate(dt)
    end
end

local rectangle = rootObj:subclass("Rectangle")

function rectangle:init(properties, children)
    self.borderWidth = 1
    self.borderColor = {0,0,1}
    self.pixelSize = jutils.vec2.new(200, 100)
    self.pixelPosition = jutils.vec2.new(0, 0)
    self.scaleSize = jutils.vec2.new(0, 0)
    self.scalePosition = jutils.vec2.new(0, 0)
    self.borderEnabled = true
    self.bevel = 0
    self.enabled = true
    self.backgroundColor = {1,1,1}

    rootObj.init(self, properties, children)
end

function rectangle:update(dt, parent)
    rootObj.update(self, dt, parent)
end

function rectangle:draw(parent)
    if self.enabled then
        local absSize = self.absoluteSize
        local absPos = self.absolutePosition

        if self.borderEnabled then
            love.graphics.setColor(self.borderColor)
            love.graphics.setLineWidth(self.borderWidth)
            love.graphics.rectangle("line", absPos.x, absPos.y, absSize.x, absSize.y, self.bevel)
        end

        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", absPos.x, absPos.y, absSize.x, absSize.y, self.bevel)
    end
end

local text = rootObj:subclass("Text")

function text:init(props, children)

    self.text = "Sample Text"
    self.font = nil
    self.textColor = {1, 0, 0}
    self.textXAlign = "left"
    self.textYAlign = "top"

    rootObj.init(self, props, children)
end

function text:update() end

function text:draw(parent)
    local parentPos = parent.absolutePosition
    local parentSize = parent.absoluteSize

    local font = self.font
    if not font then font = love2dDefaultFont end
    love.graphics.setFont(font)

    local currentFontHeight = font:getHeight()
    
    love.graphics.setColor(self.textColor)

    local yPos = parentPos.y


    if self.textYAlign == "center" then
        yPos = parentPos.y + (parentSize.y/2) - (currentFontHeight/2)
    elseif self.textYAlign == "bottom" then
        yPos = parentPos.y + parentSize.y - currentFontHeight
    end

    love.graphics.printf( self.text, parentPos.x, yPos, parentSize.x, self.textXAlign)

    love.graphics.setFont(love2dDefaultFont)
end

local textinput = text:subclass("TextInput")

function textinput:init(properties, children)
    self.isFocused = true
    self.defaultText = ""

    self.onInput = function(text) end

    
    self.cursor = ""
    self.time = 0.0

    self.keepHistory = false
    self.history = {}
    self.historyIndex = 1
    self.grabFocusOnReturn = true
    self.clearOnReturn = true
    self.clearTextOnFocus = false
    self.clearDefaultOnFocus = false

    
    self.cursorText = "|"

    text.init(self, properties, children)
    self._cursor = #self.defaultText
    self.internalText = self.defaultText
end

function textinput:keypressed(key)
    if self.isFocused ~= true then return end

    if key == "backspace" and self._cursor > 0 then
       --[[ if self._cursor > #self.internalText then
            self._cursor = #self.internalText
        end]]
        self.internalText = string.sub(self.internalText, 1, self._cursor-1)..string.sub(self.internalText, self._cursor+1)
        self._cursor = self._cursor - 1
    elseif key == "left" then
        self._cursor = math.max(0, self._cursor-1)
    elseif key == "right" then
        self._cursor = math.min(self.internalText:len(), self._cursor+1)
    elseif key == "up" then
        if self.keepHistory then
            
            self.internalText = self.history[self.historyIndex] or ""
            self.historyIndex = self.historyIndex - 1
            if self.historyIndex < 1 then self.historyIndex = 1 end
            self._cursor = #self.internalText
        end
    elseif key == "down" then
        if self.keepHistory then
            self.historyIndex = self.historyIndex + 1
            if self.historyIndex > #self.history then self.historyIndex = #self.history end
            self.internalText = self.history[self.historyIndex]
            self._cursor = #self.internalText
        end

    elseif key == "delete" then

    elseif key == "return" then
        
        if self.keepHistory then
            self.history[#self.history+1] = self.internalText
            self.historyIndex = #self.history
        end

        self:onInput(self.internalText)

        print(self.internalText)
        if self.clearOnReturn then
            self.internalText = ""
            self.text = ""
            self._cursor = 0
        end

        if self.grabFocusOnReturn then
            self.isFocused = true
        else
            self.isFocused = false
        end
    end

    if love.keyboard.isDown("lctrl") then

        if key == "v" then
            self:textinput(love.system.getClipboardText())
        elseif key == "c" then
            love.system.setClipboardText(self.internalText)
        end
    end
end

function textinput:textinput(t)
    if self.isFocused then
        self.internalText = string.sub(self.internalText, 1, self._cursor)..t..string.sub(self.internalText, self._cursor+1)
        self._cursor = self._cursor + #t
        self.hasBeenModified = true
    end
end

function textinput:grabFocus()
    self.isFocused = true

    if self.clearDefaultOnFocus then
        self.hasBeenModified = true
    end
end

function textinput:update(dt, parent)

    self.time = self.time + dt

    if self.time > 0.25 then
        self.cursor = (self.cursor == self.cursorText) and "" or self.cursorText
        self.time = 0
    end

    if self.isFocused then
        self.text = string.sub(self.internalText, 1, self._cursor)..self.cursor..string.sub(self.internalText, self._cursor+1)
    else
        self.text = self.internalText
    end

    text.update(self, dt, parent)
end

function textinput:draw(parent)
    text.draw(self, parent)
end


local image = rootObj:subclass("Image")

function image:init(properties, children)

    self.pixelSize = jutils.vec2.new(0, 0)
    self.pixelPosition = jutils.vec2.new(0, 0)
    self.scaleSize = jutils.vec2.new(1, 1)
    self.scalePosition = jutils.vec2.new(0, 0)
    self.image = nil
    self.quad = nil
    self.color = {1,1,1}
    self.scalingMode = "stretch" -- "repeat", "aspectratio", "stretch"
    self.rotation = 0
    self.offset = jutils.vec2.new(0, 0)

    rootObj.init(self, properties, children)
end

function image:update(dt, parent)
    rootObj.update(self, dt, parent)
end

function image:draw(parent)

    local size = self.absoluteSize
    local pos = self.absolutePosition

    local imageSizeX, imageSizeY = self.image:getDimensions()

    local imgScaleX = size.x / imageSizeX
    local imgScaleY = size.y / imageSizeY

    if self.image then

        love.graphics.setColor(self.color)
        
        if self.quad then
            love.graphics.draw( self.image, self.quad, pos.x, pos.y, self.rotation, imgScaleX, imgScaleY, self.offset.x, self.offset.y)
        else
            love.graphics.draw(self.image, pos.x, pos.y, self.rotation, imgScaleX, imgScaleY, self.offset.x, self.offset.y)
        end
    end
end

local nineslice = rootObj:subclass("NineSlice")

function nineslice:init(properties, children)

    self.pixelSize = jutils.vec2.new(0, 0)
    self.pixelPosition = jutils.vec2.new(0, 0)
    self.scaleSize = jutils.vec2.new(0.5, 1)
    self.scalePosition = jutils.vec2.new(0, 0)
    self.color = {1,1,1}
    self.imageScale = 1

    self.image = nil --love.graphics.newImage("bastard.png")

    self.sourceHeight = 48
    self.sourceWidth = 48

    self.cornerWidth = 8
    self.cornerHeight = 8

    

    rootObj.init(self, properties, children)

    self.quads = {
        topleft = love.graphics.newQuad(0, 0, self.cornerWidth, self.cornerHeight, self.sourceWidth, self.sourceHeight),
        topright = love.graphics.newQuad(self.sourceWidth-self.cornerWidth, 0, self.cornerWidth, self.cornerHeight, self.sourceWidth, self.sourceHeight),
        bottomleft = love.graphics.newQuad(0, self.sourceHeight-self.cornerHeight, self.cornerWidth, self.cornerHeight, self.sourceWidth, self.sourceHeight),
        bottomright = love.graphics.newQuad(self.sourceWidth-self.cornerWidth, self.sourceHeight-self.cornerHeight, self.cornerWidth, self.cornerHeight, self.sourceWidth, self.sourceHeight),
        left =  love.graphics.newQuad(0, self.cornerHeight, self.cornerWidth, self.sourceHeight-(self.cornerHeight*2), self.sourceWidth, self.sourceHeight),
        top = love.graphics.newQuad(self.cornerWidth, 0, self.sourceHeight-(self.cornerWidth*2), self.cornerHeight, self.sourceWidth, self.sourceHeight),
        bottom = love.graphics.newQuad(self.cornerWidth, self.sourceHeight-self.cornerHeight, self.sourceWidth-(self.cornerWidth*2), self.cornerHeight, self.sourceWidth, self.sourceHeight),
        right = love.graphics.newQuad(self.sourceWidth-self.cornerWidth, self.cornerHeight, self.cornerWidth, self.sourceHeight-(self.cornerHeight*2), self.sourceWidth, self.sourceHeight),
        center = love.graphics.newQuad(self.cornerWidth, self.cornerHeight, self.sourceWidth-(self.cornerWidth*2), self.sourceHeight-(self.cornerHeight*2), self.sourceWidth, self.sourceHeight),
    }
end

function nineslice:update(dt, parent)
    rootObj.update(self, dt, parent)
end

function nineslice:draw(parent)

    local size = self.absoluteSize
    local pos = self.absolutePosition

    local cornerW = self.cornerWidth*self.imageScale
    local cornerH = self.cornerHeight*self.imageScale

    local imgScaleX = (size.x-(cornerW*2)) / (self.sourceWidth-(self.cornerWidth*2))
    local imgScaleY = (size.y-(cornerH*2)) / (self.sourceHeight-(self.cornerHeight*2))

    if self.image then

        love.graphics.setColor(self.color)
        -- draw corner quads
        love.graphics.draw(self.image, self.quads.topleft, pos.x, pos.y, 0, self.imageScale, self.imageScale)
        love.graphics.draw(self.image, self.quads.bottomleft, pos.x, pos.y+(size.y-cornerH), 0, self.imageScale, self.imageScale)
        love.graphics.draw(self.image, self.quads.bottomright, pos.x+(size.x-cornerW), pos.y+(size.y-cornerH), 0, self.imageScale, self.imageScale)
        love.graphics.draw(self.image, self.quads.topright, pos.x+(size.x-cornerW), pos.y, 0, self.imageScale, self.imageScale)

        -- draw edges
        love.graphics.draw(self.image, self.quads.left, pos.x, pos.y+cornerH, 0, self.imageScale, imgScaleY)
        love.graphics.draw(self.image, self.quads.top, pos.x+cornerW, pos.y, 0, imgScaleX, self.imageScale)
        love.graphics.draw(self.image, self.quads.right, (pos.x+size.x) - cornerW, pos.y+cornerH, 0, self.imageScale, imgScaleY)
        love.graphics.draw(self.image, self.quads.bottom, pos.x+cornerW, (pos.y+size.y)-cornerH, 0, imgScaleX, self.imageScale)
        -- center
        love.graphics.draw(self.image, self.quads.center, pos.x+cornerW, pos.y+cornerH, 0, imgScaleX, imgScaleY)
    end
end

local list = rootObj:subclass("List")

function list:init(properties, children)

    self.padding = 0
    self.sortFromBottom = false

    rootObj.init(self, properties, children)
end

function list:update(dt, parent)
    self.absolutePosition = parent.absolutePosition
    self.absoluteSize = parent.absoluteSize
end

function list:updateChildren(dt, children)

    local posHSoFar = 0
    for index, child in ipairs(children) do
        --print(child.bevel)
        child.pixelPosition.x = 0
        child.pixelPosition.y = posHSoFar
        child.scalePosition.x = 0
        child.scalePosition.y = 0
        posHSoFar = posHSoFar + child.absoluteSize.y + self.padding
    end
end

local grid = rootObj:subclass("Grid")

function grid:init(props, children)
    self.cellScaleSize = jutils.vec2.new(0, 0)
    self.cellPixelSize = jutils.vec2.new(100, 100)
    self.cellPadding = jutils.vec2.new(4, 4)
    rootObj.init(self, props, children)
end

function grid:update(dt, parent)
    self.absolutePosition = parent.absolutePosition
    self.absoluteSize = parent.absoluteSize
end

function grid:updateChildren(dt, children)

    local totalCellSizeX = ((self.absoluteSize.x * self.cellScaleSize.x) + self.cellPixelSize.x) + self.cellPadding.x
    local totalCellSizeY = ((self.absoluteSize.y * self.cellScaleSize.y) + self.cellPixelSize.x) + self.cellPadding.y

    local numFittingX = self.absoluteSize.x / totalCellSizeX
    local numFittingY = self.absoluteSize.y / totalCellSizeY

    local row = 0
    local column = 0
    for index, child in pairs(children) do

        --print(child.bevel)
        child.pixelPosition.x = row*totalCellSizeX
        child.pixelPosition.y = column*totalCellSizeX
        child.scalePosition.x = 0
        child.scalePosition.y = 0
        child.pixelSize = self.cellPixelSize
        child.scaleSize = self.cellScaleSize

        row = row + 1

        if row >= (numFittingX-1) then
            row = 0
            column = column + 1
        end
    end
end

local mouseListener = rootObj:subclass("mouse")

function mouseListener:init(properties, children)

    self.mouseButton = 1
    self.mouseInside = false
    self.mouseDown = false
    self.mousePressed = false
    self.mouseEnter = function() end
    self.mouseExit = function() end
    self.mouseButtonUp = function() end
    self.mouseButtonDown = function() end

    self._mouseEntranceDebounce = false

    rootObj.init(self, properties, children)
end

function mouseListener:update(dt, parent)
    local parentPos = parent.absolutePosition
    local parentSize = parent.absoluteSize

    local mPos = jutils.vec2.new(love.mouse.getX(), love.mouse.getY())

    if mPos.x > parentPos.x and mPos.y > parentPos.y and mPos.x < (parentPos.x+parentSize.x) and mPos.y < (parentPos.y+parentSize.y) then
        if self.mouseInside == false then
            self:mouseEnter()
        end
        self.mouseInside = true
    
    else
        if self.mouseInside == true then
            self:mouseExit()
        end
        self.mouseInside = false
    end

    if love.mouse.isDown(self.mouseButton) then
        self.mousePressed = true
        if self.mouseInside == true then
            if self.mouseDown == false then
                self:mouseButtonDown()
            end
            self.mouseDown = true
        end
    else
        self.mousePressed = false
        if self.mouseDown == true then
            if self.mouseInside then
                self:mouseButtonUp()
            end
        end
        self.mouseDown = false
    end
end

local slider = rectangle:subclass("Slider")

function slider:init(properties, children)

    self.mouseListener = mouseListener:new({})

    self.valueChanged = function(newval) end

    self.scrubber = rectangle:new({
        scaleSize = jutils.vec2.new(0, 1),
        pixelSize = jutils.vec2.new(20, 0),
        backgroundColor = {0.5, 0.5, 0.5}
    })

    self.defaultValue = 0
    self.maxValue = 10
    self.minValue = -10
    self.increment = 1
    self.smooth = false

    self.value = self.defaultValue

    self.valuePercent = 0

    self.mouseGrabbed = false

    self.valueDisplayModifier = function(prop) return prop end

    rectangle.init(self, properties, children)
end

function slider:update(dt, parent)
    rectangle.update(self, dt, parent)

    self.mouseListener:update(dt, self)
    self.scrubber:update(dt, self)


    if love.mouse.isDown(1) then
        if self.mouseListener.mouseInside == true and self.mouseGrabbed == false then
            print("grab")
            self.mouseGrabbed = true
        end
    else
        if self.mouseGrabbed == true then
            print("release")
            self.mouseGrabbed = false
            self.valueChanged(self.value)
        end
    end

    if self.mouseGrabbed then
        local mx, my = love.mouse.getX(), love.mouse.getY()
        local pos = self.absolutePosition
        local size = self.absoluteSize

        local diff = love.mouse.getX() - pos.x

        local frac = diff / size.x

        if frac > 1 then frac = 1 end
        if frac < 0 then frac = 0 end

        self.valuePercent = frac

        local scrubPos = jutils.math.clamp(0, (frac*size.x)-(self.scrubber.pixelSize.x/2), size.x-(self.scrubber.pixelSize.x))
        local range = self.maxValue-self.minValue

        if self.smooth == false then
            local thingy = jutils.math.multiple(frac*range, self.increment)/range
            scrubPos = jutils.math.clamp(0, (thingy*size.x)-(self.scrubber.pixelSize.x/2), size.x-(self.scrubber.pixelSize.x))
        end
        self.scrubber.pixelPosition.x = scrubPos
        
        local val = jutils.math.multiple((frac*range), self.increment) + self.minValue

        self.value = val

    end
end

function slider:draw(parent)
    rectangle.draw(self, parent)

    self.scrubber:draw(self)
end

local guiscene = jutils.object:subclass("guiscene")

function guiscene:init(props, objectTree)

    self.absoluteSize = jutils.vec2.new(love.graphics.getDimensions())
    self.absolutePosition = jutils.vec2.new(0, 0)
    self.visible = true
    self.listenInput = true

    self.children = objectTree
end

function guiscene:find(childname)
    return recursiveSearch(self, childname)

end

local function recursiveUpdate(parent, delta)
    if not parent.children then return end
    if parent.updateChildren then
        parent:updateChildren(delta, parent.children)
    end
    for key, object in pairs(parent.children) do
        if object then
            object:update(delta, parent)
            recursiveUpdate(object, delta)
        end
    end
end

local function recursiveDraw(parent)
    if not parent.children then return end
    for key, object in pairs(parent.children) do
        if object.draw then
            object:draw(parent)
            
        end
        recursiveDraw(object)
    end
end

local function traverse(parent, childTable, searchedID)

    for obj, children in pairs(childTable) do
        if obj.id == searchedID then return obj end
        traverse(obj, children, searchedID)
    end
end

function guiscene:findObjectByID(id)
    return traverse(self, self.objects, id)
end

function guiscene:updateChildren(delta, children)

end


function guiscene:update(dt)
    self.absoluteSize = jutils.vec2.new(love.graphics.getDimensions())
    recursiveUpdate(self, dt)
end

function guiscene:draw()
    recursiveDraw(self)
end

local function tooltipTemplate(style, textStyle, listenerProperties)

    return {
        tooltip = {
            rectangle:new(style),
            {
                text = {text:new(textStyle)}

            }
        },
        listener = {
            mouseListener:new(listenerProperties)
        }
    }
end

return {
    scene = guiscene,
    rectangle = rectangle,
    text = text,
    textinput = textinput,
    image = image,
    nineslice = nineslice,
    slider = slider,
    list = list,
    grid = grid,
    mouseListener = mouseListener,
    templates = {
        tooltip = tooltipTemplate,
    },
    enums = {
        textXAlign = {
            LEFT = "left",
            CENTER = "center",
            RIGHT = "right"
        },
        textYAlign = {
            TOP = "top",
            CENTER = "center",
            BOTTOM = "bottom",
        }
    }
}