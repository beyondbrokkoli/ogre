require("global")
require("display/board")
require("display/interface")
require("game/setup")

local resize, B

local standard = Map:new(GRID_COUNT, GRID_COUNT) -- Using your industrial Map class
standard:set({x=1, y=1}, {type="text", val="Hello, World"})

function CalculateTextBounds(text)
    local width = UI_FONT:getWidth(text)
    local height = UI_FONT:getHeight()
    -- Map these pixels to your logical grid units
   return math.ceil(width / cellWidth), math.ceil(height / cellHeight)
end

function love.load()
    local x, y = love.graphics.getDimensions()
    local bdim = Layout(x, y, love.window.getFullscreen())
    B = Board:new(standard)
    B:init(bdim)
    -- Define these inside love.load to avoid globals
    UI_FONT = UI_FONT or love.graphics.newFont(12)

end

function love.draw()
    if resize then return end

    -- Define your viewport dimensions (e.g., 8x8 or 10x10)
    -- This determines how many tiles are visible on screen.
    local vw, vh = GRID_COUNT, GRID_COUNT

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
    -- viewW and viewH should be the same ones used in Board:draw
    local vw, vh = 10, 10

    if key == "up"    then B:moveCamera(0, -1, vw, vh) end
    if key == "down"  then B:moveCamera(0,  1, vw, vh) end
    if key == "left"  then B:moveCamera(-1, 0, vw, vh) end
    if key == "right" then B:moveCamera( 1, 0, vw, vh) end
end

-- Add this to your main.lua
function love.mousepressed(x, y, button)
    Mouse:pressed(B, x, y, button)
end
