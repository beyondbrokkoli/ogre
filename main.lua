require("global")
require("display/interface")
require("display/board")
require("display/mouse")
require("game/setup")
local resize
local B

-- In main.lua, initialize a timer map
local keyTimers = { left = 0, right = 0, up = 0, down = 0 }
local delay = 0.3 -- Initial pause
local repeatRate = 0.05 -- Repeat interval

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
    -- 1. Input Handling (Always safe)
    handleCameraInput(dt)

    -- 2. Resize Logic (The "Cool Down" period)
    if resize then
        resize = resize + dt
        if resize > 0.5 then
            resize = false
            local w, h = love.graphics.getDimensions()
            B:init(Layout(w, h, love.window.getFullscreen()))
        end
    -- 3. Only sync Mouse if the board is stable
    else
        Mouse:update(B)
    end
end

function love.resize(x, y) resize = 0 end
function love.keypressed(key)
    if keyTimers[key] then -- Only process keys we track
        moveCameraFromKey(key)
        keyTimers[key] = 0 -- Optional: instant reset on new press
    end
end

function love.mousepressed(x, y, button)
    Mouse:pressed(B, x, y, button)
end
function moveCameraFromKey(key)
    local dirs = {up={0,-1}, down={0,1}, left={-1,0}, right={1,0}}
    local d = dirs[key]
    if d then B:moveCamera(d[1], d[2]) end
end

function handleCameraInput(dt)
    for key, _ in pairs(keyTimers) do
        if love.keyboard.isDown(key) then
            keyTimers[key] = keyTimers[key] + dt
            if keyTimers[key] > delay then
                moveCameraFromKey(key)
                keyTimers[key] = delay - repeatRate
            end
        else
            keyTimers[key] = 0
        end
    end
end
