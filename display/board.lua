-- display/board.lua
require("global")

Board = {}

-- adding empty sprites table to keep the ghosts alive
function Board:new(gameState)
    return setmetatable({
        state = gameState,
        sprites = {},
        camera = {x = 0, y = 0},
        squareSize = 40 -- Fixed tile size
    }, {__index = Board})
end

function Board:init(t)
    self.bX, self.bY = t.ox, t.oy

    -- Calculate how many tiles fit in the current window size
    self.viewW = math.floor(t.sizeW / self.squareSize)
    self.viewH = math.floor(t.sizeH / self.squareSize)
   -- gemini read my mind when removing the loadAssets function
    -- self:loadAssets("assets")
end

function Board:drawView()
    -- Use self.viewW/H instead of globals
    for x = 1, self.viewW do
        local mapX = x + self.camera.x
        for y = 1, self.viewH do
            local mapY = y + self.camera.y
            local cellData = self.state:get({x = mapX, y = mapY})

            if cellData then
                -- Direct pixel calculation (removes GridMap dependency)
                local px = self.bX + (x - 1) * self.squareSize
                local py = self.bY + (y - 1) * self.squareSize

                self:drawCellHighlight(px, py, mapX, mapY)
                self:drawItem(cellData, px, py)
            end
        end
    end
end

function Board:drawItem(obj, px, py)
    if obj.type == "text" then
        love.graphics.print(obj.val, px + 4, py + 4)
    elseif self.sprites[obj.type] then
        local img = self.sprites[obj.type]
        -- Draw centered in the tile
        local half = self.squareSize / 2
        love.graphics.draw(img, px + half, py + half, 0, 1, 1,
            math.floor(img:getWidth()/2), math.floor(img:getHeight()/2))
    end
end

-- sx/sy (screen coords) replaced with px/py (actual pixels)
function Board:drawCellHighlight(px, py, wx, wy)
    local cell = self.state:get({x = wx, y = wy})
    local isHovered = (wx == Mouse.hover.x and wy == Mouse.hover.y)

    if (cell and cell.active) or isHovered then
        local r, g, b, a = 0.2, 0.6, 1, 0.5
        if isHovered and not (cell and cell.active) then r, g, b, a = 1, 1, 1, 0.2 end

        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", px, py, self.squareSize, self.squareSize)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Board:screenToGrid(mX, mY)
    local x = math.floor((mX - self.bX) / self.squareSize) + 1
    local y = math.floor((mY - self.bY) / self.squareSize) + 1
    return x, y
end

function Board:toWorld(sx, sy)
    local wx, wy = sx + self.camera.x, sy + self.camera.y
    if wx >= 1 and wx <= GRID_COUNT and wy >= 1 and wy <= GRID_COUNT then
        return wx, wy
    end
end

function Board:moveCamera(dx, dy)
    -- Clamping using the dynamic view width/height
    local maxCamX = GRID_COUNT - self.viewW
    local maxCamY = GRID_COUNT - self.viewH
    self.camera.x = math.max(0, math.min(self.camera.x + dx, maxCamX))
    self.camera.y = math.max(0, math.min(self.camera.y + dy, maxCamY))
end
