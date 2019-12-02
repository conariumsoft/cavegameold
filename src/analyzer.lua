return function(args)
    love.window.setTitle("MAP ANALYSIS TOOL")
	love.window.setMode(
		1280, 720,
		{
			fullscreen = false,
			resizable = false,
			vsync = false,
		}
    )

    local render_canvas = love.graphics.newCanvas(1280, 720)

    function love.update(dt)

    end

    function love.draw()

    end


    function love.quit()

    end
end


