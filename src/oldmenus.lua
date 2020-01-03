--- Layout and configuration of menus, & scripting of UI elements.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software


local jui = require("src.jui")
local config = require("config")

local jutils = require("src.jutils")
local settings_mod = require("src.settings")

local guiutil = require("src.guiutil")

--- Menu Module
-- @class module
local menus = {}

-- menu scenes
local main
local newWorld
local loadWorld
local settings

-- static UI components shared between menus
local menu_background = jui.image:new({
    image = love.graphics.newImage("assets/brickbg.png"),
    color = {0.6, 0.6, 0.6},
})

local menu_frame = jui.rectangle:new({
    scaleSize = jutils.vec2.new(1, 1),
    pixelSize = jutils.vec2.new(-40, -20),
    pixelPosition = jutils.vec2.new(20, 10),
    backgroundColor = {0,0,0,0},
    borderEnabled = false,
})

local menu_topbar = jui.rectangle:new({
    borderEnabled = false,
    scaleSize = jutils.vec2.new(1, 0),
    pixelSize = jutils.vec2.new(0, 50),
    backgroundColor = {0,0,0,0},
})

local menu_content = jui.rectangle:new({
    scaleSize = jutils.vec2.new(1, 1),
    pixelSize = jutils.vec2.new(0, -70),
    pixelPosition = jutils.vec2.new(0, 70),
    backgroundColor = {0,0,0,0},
    borderEnabled = false,
})

-- core UI styles
local mainMenuButtonStyle = {
    scaleSize = jutils.vec2.new(1, 0),
    pixelSize = jutils.vec2.new(0, 50)
}

local settingsButtonStyle = {
    scaleSize = jutils.vec2.new(1, 0),
    pixelSize = jutils.vec2.new(0, 30)
}

local core_button_style = {
    image = love.graphics.newImage("assets/ui/button.png"),
    sourceWidth = 16,
    sourceHeight = 16,
    cornerWidth = 7,
    cornerHeight = 7,
    imageScale = 2,
}

local splashUI = {
    bg = {
        menu_background,
        {
            text = {
                jui.text:new({
                    text = "conarium software",
                    font = guiutil.fonts.font_24,
                    textColor = jutils.color.fromHex("#FFFFFF"),
                    textXAlign = "center",
                    textYAlign = "center",
                })
            }
        }
    }
}

local splash = jui.scene:new({}, splashUI)

local current_menu = splash

local comp_generic_back_button = guiutil.make_button({text="BACK"}, {
    pixelSize = jutils.vec2.new(100, 40),
    scaleSize = jutils.vec2.new(0, 0),
    scalePosition = jutils.vec2.new(1, 0),
    pixelPosition = jutils.vec2.new(-100, 0)
}, function() current_menu = main end)

local mainUI = {
    a = {
        menu_background,
        {
            b = {
                jui.rectangle:new({
                    scaleSize = jutils.vec2.new(1, 1),
                    pixelSize = jutils.vec2.new(-40, -20),
                    pixelPosition = jutils.vec2.new(20, 10),
                    backgroundColor = {0,0,0,0},
                    borderEnabled = false,
                }), 
                {
                    top = {
                        menu_topbar,
                        {
                            title = {
                                jui.text:new({
                                    text = "CAVE GAME",
                                    font = guiutil.fonts.font_30,
                                    textColor = jutils.color.fromHex("#FFFFFF"),
                                    textXAlign = "left",
                                    textYAlign = "center",
                                })
                            },
                            subtitle = {
                                jui.text:new({
                                    text = "v"..config.GAME_VERSION..", copyright conarium software",
                                    font = guiutil.fonts.font_12,
                                    textColor = jutils.color.fromHex("#FFFFFF"),
                                    textXAlign = "right",
                                    textYAlign = "center",
                                })
                            } 
                        }
                    },

                    buttons = {
                        jui.rectangle:new({
                            scaleSize = jutils.vec2.new(0.3, 0.6),
                            pixelSize = jutils.vec2.new(0, -60),
                            pixelPosition = jutils.vec2.new(0, 60),
                            scalePosition = jutils.vec2.new(0.35, 0.2),
                            backgroundColor = {0,0,0,0},
                            borderEnabled = false,
                        }),
                        {
                            childr = {
                                jui.list:new({padding = 24}),
                                {
                                    [1] = guiutil.make_button({text = "NEW WORLD"}, mainMenuButtonStyle, function() current_menu = newWorld end),
                                    [2] = guiutil.make_button({text = "LOAD WORLD"}, mainMenuButtonStyle, function() current_menu = loadWorld end),
                                    [3] = guiutil.make_button({text = "SETTINGS"}, mainMenuButtonStyle, function() current_menu = settings end),
                                    [4] = guiutil.make_button({text = "QUIT"}, mainMenuButtonStyle, function() os.exit() end),
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

local 

local newWorldUI = {
    a = {
        menu_background,
        {
            b = {
                menu_frame, 
                {
                    top = {
                        menu_topbar,
                        {
                            title = {
                                jui.text:new({
                                    text = "NEW WORLD",
                                    font = guiutil.fonts.font_30,
                                    textColor = jutils.color.fromHex("#FFFFFF"),
                                    textXAlign = "left",
                                    textYAlign = "center",
                                })
                            },
                            back = comp_generic_back_button
                        } 
                    },
                    mid = {
                        menu_content,
                        {
                            worldNameField = {
                                jui.nineslice:new({
                                    image = love.graphics.newImage("assets/ui/button.png"),
                                    sourceWidth = 16,
                                    sourceHeight = 16,
                                    cornerWidth = 7,
                                    cornerHeight = 7,
                                    imageScale = 2,
                                    scaleSize = jutils.vec2.new(0.5, 0),
                                    scalePosition = jutils.vec2.new(0.25, 0),
                                    pixelSize = jutils.vec2.new(0, 40),
                                    pixelPosition = jutils.vec2.new(0, 0),
                                }),
                                {
                                    box = {
                                        jui.rectangle:new({
                                            scaleSize = jutils.vec2.new(01, 01),
                                            scalePosition = jutils.vec2.new(0, 0),
                                            pixelSize = jutils.vec2.new(-40, 0),
                                            pixelPosition = jutils.vec2.new(20, 0),
                                            borderEnabled = false,
                                            backgroundColor = {0,0,0,0}
                                        }),
                                        {
                                            inp = {
                                                world_name_input
                                            }
                                        }
                                        
                                    },
                                    clik = {
                                        jui.mouseListener:new({
                                            mouseButtonUp = function()
                                                world_name_input.isFocused = not world_name_input.isFocused
                                            end
                                        })
                                    }
                                }
                            },
                            goButton = guiutil.make_button({
                                text = "Create World"
                            }, {
                                scaleSize = jutils.vec2.new(0, 0),
                                scalePosition = jutils.vec2.new(0.5, 0.5),
                                pixelSize = jutils.vec2.new(260, 50),
                                pixelPosition = jutils.vec2.new(-140, 0),
                            }, function()
                                menus.world_chosen = true
                                menus.selected_world = world_name_input.internalText
                            end)
                        }
                    }
                }
            }
        }
    }
}

local load_menu_buttons_container = jui.rectangle:new({
    scaleSize = jutils.vec2.new(1, 0),
    pixelSize = jutils.vec2.new(0, 40), 
    scalePosition = jutils.vec2.new(0, 1),
    pixelPosition = jutils.vec2.new(0, -60), 
    backgroundColor = {0,0,0,0}, 
    borderEnabled = false
})

local function recursiveEnumerate(folder, fileTree, fsize)
    local lfs = love.filesystem

    fsize = fsize or 0

    local files_table = lfs.getDirectoryItems(folder)

    for _, v in ipairs(files_table) do
        local file = folder.."/"..v

        local info = love.filesystem.getInfo(file)

        if info.type == "file" then
            fsize = fsize + info.size
            fileTree = fileTree .. "\n"..file

        elseif info.type == "directory" then
            fileTree = fileTree .. "\n"..file.." (DIR"
            fileTree, fsize = recursiveEnumerate(file, fileTree, fsize)

        end
    end
    return fileTree, fsize
end

local function recursiveDelete(item)
    if love.filesystem.getInfo(item, "directory") then
		for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
			recursiveDelete(item .. "/" .. child)
			love.filesystem.remove(item .. "/" .. child)
		end
	elseif love.filesystem.getInfo(item) then
		love.filesystem.remove(item)
	end
	love.filesystem.remove(item)
end

local function jui_search(tree, objectname)
    -- TODO: make this
end

local world_menu_list = {}

local load_world_button
local copy_world_button
local delete_world_button

local world_selected_to_load = nil

local function worldBox(worldname, data)

    local title_text = jui.text:new({
        text = worldname,
        textYAlign = "center",
        textXAlign = "left",
        textColor = {0.8, 0.8, 0.8},
        font = guiutil.fonts.font_16,
    })

    local data_text = jui.text:new({
        text = data,
        textYAlign = "center",
        textXAlign = "right",
        textColor = {0.75, 0.75, 0.75},
        font = guiutil.fonts.font_16,
    })

    local rect = jui.nineslice:new({
        scaleSize = jutils.vec2.new(1, 0),
        scalePosition = jutils.vec2.new(0, 0),
        pixelSize = jutils.vec2.new(0, 60),
        pixelPosition = jutils.vec2.new(0, 0),
        image = love.graphics.newImage("assets/ui/button.png"),
        sourceWidth = 16,
        sourceHeight = 16,
        cornerWidth = 7,
        cornerHeight = 7,
        imageScale = 2,
    })

    local box = {
        rect,
        {
            inside = {
                jui.rectangle:new({
                    backgroundColor = {0.2, 0.2, 0.2, 0},
                    borderEnabled = false,
                    scaleSize = jutils.vec2.new(1, 1),
                    pixelSize = jutils.vec2.new(-20, 0),
                    pixelPosition = jutils.vec2.new(10, 0),
                }),
                {
                    title = {title_text},
                    data = {data_text},
        
                    mclick = {
                        jui.mouseListener:new({
                            mouseEnter = function()
                                if world_selected_to_load ~= worldname then
                                    title_text.textColor = {0.7, 0.7, 0.7}
                                    data_text.textColor = {0.65, 0.65, 0.65}
                                    rect.color = {0.5, 0.5, 0.5}
                                end
                            end,
                            mouseExit = function()
                                if world_selected_to_load ~= worldname then
                                    data_text.textColor = {0.75, 0.75, 0.75}
                                    title_text.textColor = {0.8, 0.8, 0.8}
                                    rect.color = {1, 1, 1}
                                end
                            end,
        
                            mouseButtonUp = function()

                                for _, obj in pairs(world_menu_list) do
                                    local bg = obj[1]
                                    local other_title_text = obj[2]["inside"][2]["title"][1]
                                    local other_data_text = obj[2]["inside"][2]["data"][1]

                                    bg.color = {1, 1, 1}
                                    other_data_text.textColor = {0.75, 0.75, 0.75}
                                    other_title_text.textColor = {0.8, 0.8, 0.8}

                                end

                                data_text.textColor = {1,1,1}
                                title_text.textColor = {1,1,1}

                                rect.color = {0.25, 0.25, 0.25}

                                load_world_button[2]["text"][1].textColor   = {1, 1, 1}
                                copy_world_button[2]["text"][1].textColor   = {1, 1, 1}
                                delete_world_button[2]["text"][1].textColor = {1, 1, 1}

                                load_world_button[1].color   = {1, 1, 1}
                                copy_world_button[1].color   = {1, 1, 1}
                                delete_world_button[1].color = {1, 1, 1}
                                
                                world_selected_to_load = worldname
                                print("SELECT THIS WORLD", world_selected_to_load)
                            end
                        })
                    }
                }
            }
        }
    }

    return box

end

local function getWorldSaves()

    for idx, obj in pairs(world_menu_list) do
        world_menu_list[idx] = nil
    end

    for _, name in pairs(love.filesystem.getDirectoryItems("worlds")) do
        local data = love.filesystem.getInfo("worlds/"..name)
        local _, size = recursiveEnumerate("worlds/"..name, "")

        if data then
            
            local box = worldBox(name, os.date("%x %X", data.modtime)..", "..math.floor(size/(1000^2)).."mb")

            world_menu_list[#world_menu_list+1] = box
        end
    end
end

local function reset_load_menu_states()
    getWorldSaves()
    world_selected_to_load = nil
    load_world_button[2]["text"][1].textColor = {0.5, 0.5, 0.5}
    delete_world_button[2]["text"][1].textColor = {0.5, 0.5, 0.5}
    copy_world_button[2]["text"][1].textColor = {0.5, 0.5, 0.5}

    load_world_button[1].color = {0.25, 0.25, 0.25}
    copy_world_button[1].color = {0.25, 0.25, 0.25}
    delete_world_button[1].color = {0.25, 0.25, 0.25}
end

local function specific_button(text, callback)
    local box = jui.nineslice:new(jutils.table.combine(settingsButtonStyle, guiutil.core_button_style))
    local text = jui.text:new({
        font = guiutil.fonts.font_16,
        text = text,
        textColor = {0.5, 0.5, 0.5},
        textXAlign = "center",
        textYAlign = "center",
    })
    return {
        box,
        {
            text = {
                text
            },
            click = {
                jui.mouseListener:new({
                    mouseEnter = function()
                        if world_selected_to_load then
                            text.textColor = {0.7, 0.7, 0.7}
                            box.color = {0.5, 0.5, 0.5}
                        end
                    end,
                    mouseExit = function()
                        if world_selected_to_load then
                            text.textColor = {1, 1, 1}
                            box.color = {1, 1, 1}
                        end
                    end,

                    mouseButtonUp = callback
                })
            }
        }
    }
end


load_world_button = specific_button("Load World", function() 
    if world_selected_to_load then
        menus.world_chosen = true
        menus.selected_world = world_selected_to_load
    end
end)
copy_world_button = specific_button("Copy World", function()
    if world_selected_to_load then
        -- TODO: implement world copying
        reset_load_menu_states()
    end
end)
delete_world_button = specific_button("Delete World", function()
    if world_selected_to_load then
        recursiveDelete("worlds/"..world_selected_to_load)

        reset_load_menu_states()
        
    end
end)

reset_load_menu_states()

local loadWorldUI = {
a = {
    menu_background,
    {
        b = {
            menu_frame, 
            {
                top = {
                    menu_topbar,
                    {
                        title = {
                            jui.text:new({
                                text = "LOAD WORLD",
                                font = guiutil.fonts.font_30,
                                textColor = jutils.color.fromHex("#FFFFFF"),
                                textXAlign = "left",
                                textYAlign = "center",
                            })
                        },
                        back = comp_generic_back_button
                    }
                },
                worlds = {
                    jui.rectangle:new({
                        scaleSize = jutils.vec2.new(1, 1),
                        pixelSize = jutils.vec2.new(0, -150),
                        pixelPosition = jutils.vec2.new(0, 60),
                        backgroundColor = {0,0,0,0},
                        borderEnabled = false,

                    }),
                    {
                        list = {
                            jui.list:new({padding = 8,}),
                            world_menu_list,
                        }
                    }
                },
                buttons = {
                    load_menu_buttons_container,
                    {
                        l = {
                            jui.grid:new({
                                cellScaleSize = jutils.vec2.new(0.24, 1),
                                cellPixelSize = jutils.vec2.new(0, 0),
                                cellPadding = jutils.vec2.new(48, 0),
                            }),
                            {
                                [1] = load_world_button,
                                [2] = delete_world_button,
                                [3] = copy_world_button,
                            }
                        }}
}}}}}}

local volume_text = jui.text:new({
    text = "Volume: "..settings_mod.get("volume"),

})

local volume_slider = {
    jui.nineslice:new(jutils.table.combine(core_button_style, {
        scaleSize = jutils.vec2.new(1, 0),
        pixelSize = jutils.vec2.new(0, 30),
    })),
    {
        s = {
            jui.slider:new({
                scaleSize = jutils.vec2.new(1, 0),
                pixelSize = jutils.vec2.new(-20, 24),
                scalePosition = jutils.vec2.new(0, 0),
                pixelPosition = jutils.vec2.new(10, 3),
                backgroundColor = {0, 0, 0, 0},
                borderEnabled = false,
                maxValue = 100,
                minValue = 0,
                defaultValue = settings_mod.get("volume"),
                increment = 1,
                smooth = false,
                scrubber = jui.rectangle:new({
                    borderEnabled = false,
                    scaleSize = jutils.vec2.new(0, 1),
                    pixelSize = jutils.vec2.new(20, 0),
                    backgroundColor = {0.75, 0.75, 0.75}
                }),
                valueChanged = function(newval)
                    settings_mod.set("volume", newval)
                    volume_text.text = "Volume: "..newval
                end,
            }),
            {

            }
        }
    }
}

local function translateBool(b)
    return (b==true) and "ON" or "OFF"
end

local function setText(prefix, property, suffix)

    local value = settings_mod.get(property)

    suffix = suffix or ""


    if type(value) == "boolean" then
        value = translateBool(value)
    end

    return prefix..": "..value..suffix
end

--! make the buttons up here.
local vsyncbutton 
vsyncbutton = guiutil.make_button({text = setText("V-SYNC", "vsync"), font = guiutil.fonts.font_16}, settingsButtonStyle,
function()
    settings_mod.set("vsync", not settings_mod.get("vsync"))
    vsyncbutton[2]["text"][1].text = setText("V-SYNC", "vsync")
end)

local particlesbutton
particlesbutton = guiutil.make_button({text = setText("PARTICLES", "particles"), font = guiutil.fonts.font_16}, settingsButtonStyle,
function()
    settings_mod.set("particles", not settings_mod.get("particles"))
    particlesbutton[2]["text"][1].text = setText("PARTICLES", "particles")
end)

local fullscreenbutton
fullscreenbutton = guiutil.make_button({text=setText("FULLSCREEN", "fullscreen"), font = guiutil.fonts.font_16}, settingsButtonStyle,
function()
    settings_mod.set("fullscreen", not settings_mod.get("fullscreen"))
    fullscreenbutton[2]["text"][1].text = setText("FULLSCREEN", "fullscreen")
end)

local debuginfobutton
debuginfobutton = guiutil.make_button({text="DEBUG INFO: OFF", font = guiutil.fonts.font_16}, settingsButtonStyle,
function ()
    
end)

local smoothingbutton
smoothingbutton = guiutil.make_button({text="SMOOTHENING: ON", font = guiutil.fonts.font_16}, settingsButtonStyle, function()

end)


local settingsUI = {
    a = {
        menu_background,
        {
            b = {
                menu_frame, 
                {
                    top = {
                        menu_topbar,
                        {
                            title = {
                                jui.text:new({
                                    text = "SETTINGS",
                                    font = guiutil.fonts.font_30,
                                    textColor = jutils.color.fromHex("#FFFFFF"),
                                    textXAlign = "left",
                                    textYAlign = "center",
                                })
                            },
                            back = comp_generic_back_button
                        }
                    },
                    left = {
                        jui.rectangle:new({
                            scaleSize = jutils.vec2.new(0.5, 1),
                            scalePosition = jutils.vec2.new(0, 0),
                            pixelPosition = jutils.vec2.new(0, 60),
                            pixelSize = jutils.vec2.new(-10, -60),
                            backgroundColor = {0,0,0,0},
                            borderEnabled = false,
                        }),
                        {
                            list = {
                                jui.list:new({
                                    padding = 8,
                                }),
                                {
                                    [1] = vsyncbutton,
                                    [2] = particlesbutton,
                                    [3] = fullscreenbutton,
                                }
                            }
                        }
                    },
                    right = {
                        jui.rectangle:new({
                            scaleSize = jutils.vec2.new(0.5, 1),
                            scalePosition = jutils.vec2.new(0.5, 0),
                            pixelPosition = jutils.vec2.new(10, 60),
                            pixelSize = jutils.vec2.new(-10, -60),
                            backgroundColor = {0,0,0,0},
                            borderEnabled = false,
                        }),
                        {
                            list = {
                                jui.list:new({
                                    padding = 8,
                                }),
                                {
                                    [1] = volume_slider,
                                    [2] = debuginfobutton,
                                    [3] = smoothingbutton
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

main = jui.scene:new({}, mainUI)
newWorld = jui.scene:new({}, newWorldUI)
loadWorld = jui.scene:new({}, loadWorldUI)
settings = jui.scene:new({}, settingsUI)

local splash_screen_time = 1
---
menus.world_chosen = false
---
menus.selected_world = nil

function menus.keypressed(key)
    if current_menu == newWorld then
        world_name_input:keypressed(key)
    end
end

function menus.textinput(t)
    if current_menu == newWorld then
        world_name_input:textinput(t)
    end
end

-- background color gradient
-- uses a cycling value multiplied by color channels to achieve
-- a morphing and breathing effect with changing colors
-- gradient is made by lerping between the color values
-- and drawing thin horizontal bars across the screen
local first_color_cycle   =  0.2
local second_color_cycle  = -0.5
local third_color_cycle   =  0.0

-- the "base" values of each color 
local first_color_base  = {0.2, 0.3, 1.0}
local second_color_base = {1.0, 0.5, 0.0}
local third_color_base  = {0.0, 1.0, 1.0}

-- the number of separately drawn bars
-- between one color and the next
-- the actual number of bars on screen is double
local color_gradient_divisions = 10

--- Moves to a specified game menu
-- @param menu "main" / "new_world" / "load_world" / "settings"
function menus.go(menu)
    if menu == "main" then
        current_menu = main
    elseif menu == "new_world" then
        current_menu = newWorld
    elseif menu == "load_world" then
        current_menu = loadWorld
    elseif menu == "settings" then
        current_menu = settings
    end
end

--- 
function menus.update(dt)
    current_menu:update(dt)

    if current_menu == splash then
        splash_screen_time = splash_screen_time - dt

        if splash_screen_time < 0 then
            current_menu = main
        end
    end

    first_color_cycle = first_color_cycle + (dt/4)
    second_color_cycle = second_color_cycle + (dt/4)
    third_color_cycle = third_color_cycle + dt

    --print(math.sin(balls))
end


--- Love2D Draw callback
function menus.draw()


    -- calculate colors for this frame
    -- trigonometric functions are used to achieve a cycle without having
    -- to keep up with the number itself
    -- meaning we only have to increment it
    local result_color_1 = {
        first_color_base[1] * math.cos(first_color_cycle),
        first_color_base[2] * math.sin(second_color_cycle),
        first_color_base[3] * math.sin(third_color_cycle)
    }
    local result_color_2 = {
        second_color_base[1] * math.cos(first_color_cycle),
        second_color_base[2] * math.sin(second_color_cycle),
        second_color_base[3] * math.cos(third_color_cycle)
    }
    local result_color_3 = {
        third_color_base[1] * math.sin(first_color_cycle),
        third_color_base[2] * math.sin(second_color_cycle),
        third_color_base[3] * math.cos(third_color_cycle)
    }

    -- first half
    for i = 1, color_gradient_divisions do

        local height = (love.graphics.getHeight()/color_gradient_divisions)/2

        love.graphics.setColor(jutils.color.lerp(result_color_1, result_color_3, i/color_gradient_divisions))
        love.graphics.rectangle("fill", 0, (i-1)*height, love.graphics.getWidth(), height)

    end
    -- draw second half
    for i = 1, color_gradient_divisions do
        local height = (love.graphics.getHeight()/color_gradient_divisions)/2

        love.graphics.setColor(jutils.color.lerp(result_color_3, result_color_2, i/color_gradient_divisions))
        love.graphics.rectangle("fill", 0, (love.graphics.getHeight()/2)+(i-1)*height, love.graphics.getWidth(), height)
    end
    current_menu:draw()
end

return menus