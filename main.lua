require("global")
require("display/board")
require("display/interface")
require("game/game")

local standard = {
    [1] = {
        [1] = "Hello, World"
    }
}

local resize, I, B, G

function love.load()
    local x, y = love.graphics.getDimensions()
    local bdim = Layout(x, y, love.window.getFullscreen())
    G = Game(standard)
    B = Board:new(standard)
    B:init(bdim)
end

function love.draw()
    if resize then return end

    -- 1. Draw the board background (logic moved into Board:draw)
    -- 2. Draw the game state
    B:draw(G.state)
    -- Industrial Test: Draw a marker in cell 1,1
    local cell = B.grid[1][1]
    love.graphics.setColor(1, 1, 0) -- Yellow
    love.graphics.print(standard[1][1], B.bX + cell.tx, B.bY + cell.cy)
end

function love.update(dt)
    if resize then
        resize = resize + dt
        if resize > 0.5 then
            resize = false
            local x, y = love.graphics.getDimensions()
            B:init(Layout(x, y, love.window.getFullscreen()))
        end
    end
end

function love.resize(x, y) resize = 0 end
