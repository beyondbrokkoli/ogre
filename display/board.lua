-- display/board.lua
require("display/graphics")
require("global")

Board = {}

function Board:new(gameState)
    local d = {
        state = gameState,
        camera = {x = 0, y = 0}
    }
    setmetatable(d, {__index = Board})
    return d
end

-- In Board:init (display/board.lua)
function Board:init(t)
    self.bX, self.bY = t.ox, t.oy
    -- Use a global or a passed-in constant for the viewport max size
    local viewMax = 10
    self.squareSize = math.floor(t.size / viewMax)

    -- GridMap needs to know how many slots to pre-calculate
    self.grid = GridMap(viewMax, viewMax, self.squareSize)
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

--- RENDERING ---

function Board:drawView(viewW, viewH)
    for x = 1, viewW do
        local mapX = x + self.camera.x
        local column = self.state.storage[mapX]

        if column then
            for y = 1, viewH do
                local mapY = y + self.camera.y
                local cellData = column[mapY]

                if cellData then
                    -- Efficiency: Pass mapX/Y directly to avoid re-calculation
                    self:drawCellHighlight(x, y, mapX, mapY)
                    self:drawItem(cellData, x, y)
                end
            end
        end
    end
end

function Board:drawItem(obj, x, y)
    local cell = self.grid.storage[x][y]
    if not cell then return end -- Safety rail for dynamic resizing

    if obj.type == "text" then
        love.graphics.print(obj.val, math.floor(self.bX + cell.tx), math.floor(self.bY + cell.cy))
    elseif self.sprites[obj.type] then
        local img = self.sprites[obj.type]
        local drawX = math.floor(self.bX + cell.cx)
        local drawY = math.floor(self.bY + cell.cy)
        local ox = math.floor(img:getWidth() / 2)
        local oy = math.floor(img:getHeight() / 2)

        love.graphics.draw(img, drawX, drawY, 0, 1, 1, ox, oy)
    end
end

-- old drawCellHighlight retained for reference, smileyface
function Board:old_drawCellHighlight(sx, sy, wx, wy)
    local cell = self.state.storage[wx][wy]
    if cell and cell.active then
        local dX = math.floor(self.bX + (sx - 1) * self.squareSize)
        local dY = math.floor(self.bY + (sy - 1) * self.squareSize)

        love.graphics.setColor(0.2, 0.6, 1, 0.5) -- Industrial Blue
        love.graphics.rectangle("fill", dX, dY, self.squareSize, self.squareSize)
        love.graphics.setColor(1, 1, 1, 1) -- Reset
    end
end
-- In display/board.lua

function Board:drawCellHighlight(sx, sy, wx, wy)
    local cell = self.state.storage[wx][wy]

    -- 1. Check if the mouse is currently hovering over THIS world tile
    local isHovered = (wx == Mouse.hover.x and wy == Mouse.hover.y)

    -- 2. Draw if active OR hovered
    if (cell and cell.active) or isHovered then
        local dX = math.floor(self.bX + (sx - 1) * self.squareSize)
        local dY = math.floor(self.bY + (sy - 1) * self.squareSize)

        if isHovered and not (cell and cell.active) then
            love.graphics.setColor(1, 1, 1, 0.2) -- Subtle white for hover
        else
            love.graphics.setColor(0.2, 0.6, 1, 0.5) -- Industrial Blue for active
        end

        love.graphics.rectangle("fill", dX, dY, self.squareSize, self.squareSize)
        love.graphics.setColor(1, 1, 1, 1) -- Always reset!
    end
end
--- LOGIC & COORDINATES ---

function Board:screenToGrid(mX, mY)
    local x = math.floor((mX - self.bX) / self.squareSize) + 1
    local y = math.floor((mY - self.bY) / self.squareSize) + 1
    return x, y
end

function Board:toWorld(sx, sy)
    local wx = sx + self.camera.x
    local wy = sy + self.camera.y
    if self.state.storage[wx] and self.state.storage[wx][wy] then
        return wx, wy
    end
    return nil
end

function Board:moveCamera(dx, dy, viewW, viewH)
    -- Total map size - visible area
    local maxCamX = #self.state.storage - viewW
    local maxCamY = #self.state.storage[1] - viewH

    -- Clamp between 0 and Max to protect the "ghost"
    self.camera.x = math.max(0, math.min(self.camera.x + dx, maxCamX))
    self.camera.y = math.max(0, math.min(self.camera.y + dy, maxCamY))
end
