require("global")
require("display/interface")
require("display/board")
require("display/mouse")
require("game/setup")
local resize, B

function CalculateTextBounds(text)
    local width = UI_FONT:getWidth(text)
    local height = UI_FONT:getHeight()
    -- Map these pixels to your logical grid units
   return math.ceil(width / cellWidth), math.ceil(height / cellHeight)
end

function love.load()
    local x, y = love.graphics.getDimensions()
    local bdim = Layout(x, y, love.window.getFullscreen())
    -- not quite there but its a start
    local gc = GRID_COUNT
    Data_Init("terrain", gc, gc)
    Data_Init("actors", gc, gc)
    Data_Init("hello", gc, gc)
    -- Now you can safely use your Map handles
    local terrainMap = Map:new("terrain")
    local actorMap = Map:new("actors")
    local helloWorld = Map:new("hello") -- Explicitly assign a layer
    helloWorld:set({x=1, y=1}, {type="text", val="Hello, World"})

    B = Board:new(helloWorld)
    B:init(bdim)
    -- Define these inside love.load to avoid globals
    UI_FONT = UI_FONT or love.graphics.newFont(12)

end

function love.draw()
    if resize then return end

    -- Define your viewport dimensions (e.g., 8x8 or 10x10)
    -- This determines how many tiles are visible on screen.
    local vw, vh = VIEW_W, VIEW_H

    -- 1. Draw everything (Highlights, Sprites, and Text)
    -- This uses the camera-aware mapX/mapY logic we perfected.
    B:drawView(vw, vh)

    -- 2. Optional: Draw UI elements on top that don't move with the camera
    -- love.graphics.print("Camera Pos: "..B.camera.x..","..B.camera.y, 10, 10)
end

function love.update(dt)
    if not resize then
        Mouse:update(B) -- Keep the mouse in sync with the board
    else
        -- ... existing resize logic
        resize = resize + dt
        if resize > 0.5 then
            resize = false
            local x, y = love.graphics.getDimensions()
            B:init(Layout(x, y, love.window.getFullscreen()))
        end
    end
end

function love.resize(x, y) resize = 0 end

function love.keypressed(key)
    local dx, dy = 0, 0
    if key == "up"    then dy = -1
    elseif key == "down"  then dy = 1
    elseif key == "left"  then dx = -1
    elseif key == "right" then dx = 1
    end

    if dx ~= 0 or dy ~= 0 then
        B:moveCamera(dx, dy)
    end
end

function love.mousepressed(x, y, button)
    Mouse:pressed(B, x, y, button)
end
