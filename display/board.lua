require("display/graphics")
require("global")

Board = {}

function Board:new(pos)
    local d = {
        settings = { style = 1, color = 2 },
        view = { x = 1, y = 1 },
        isFlipped = false,
        sprites = {},
        grid = nil
    }
    setmetatable(d, {__index = Board})
    return d
end

function Board:init(t)
    self.bX, self.bY = t.ox, t.oy
    self.squareSize = math.floor(t.size / GRID_WIDTH + 0.5)

    -- Pre-calculate coordinates once, refresh only on resize/zoom
    self.grid = GridMap(self.squareSize)
    self:loadAssets("assets")
end

function Board:loadAssets(path)
    self.sprites = {}
    local files = love.filesystem.getDirectoryItems(path)
    for _, file in ipairs(files) do
        if file:match("%.png$") then
            local name = file:gsub("%.png$", "")
            self.sprites[name] = love.graphics.newImage(path .. "/" .. file)
        end
    end
end

function Board:draw(gameState)
    for x, col in pairs(gameState) do
        for y, sprite in pairs(col) do
            if sprite then
                self:drawSprite(sprite, x, y)
            end
        end
    end
end

function Board:drawSprite(name, x, y)
    -- Handle flip logic for the viewport
    local rx = self.isFlipped and (GRID_WIDTH - x + 1) or x
    local ry = self.isFlipped and (GRID_HEIGHT - y + 1) or y

    local cell = self.grid[rx][ry]
    local img = self.sprites[name]

    if img then
        -- Industrial direct-draw using pre-calculated anchors
        love.graphics.draw(img, self.bX + cell.cx, self.bY + cell.cy, 0, 1, 1, img:getWidth()/2, img:getHeight()/2)
    end
end

function Board:screenToGrid(mX, mY)
    local x = math.floor((mX - self.bX) / self.squareSize) + 1
    local y = math.floor((mY - self.bY) / self.squareSize) + 1
    -- Apply flip inverse if needed
    return self.isFlipped and (GRID_WIDTH - x + 1) or x, self.isFlipped and (GRID_HEIGHT - y + 1) or y
end
