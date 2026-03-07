-- display/board.lua
require("display/graphics")
require("global")

Board = {}

function Board:new(gameState)
    return setmetatable({
        state = gameState,
        camera = {x = 0, y = 0}
    }, {__index = Board})
end

function Board:init(t)
    self.bX, self.bY = t.ox, t.oy
    -- Sync grid cache with the global viewport size
    self.squareSize = math.floor(t.size / VIEW_W)
    self.grid = GridMap(VIEW_W, VIEW_H, self.squareSize)
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

function Board:drawView()
    for x = 1, VIEW_W do
        local mapX = x + self.camera.x
        for y = 1, VIEW_H do
            local mapY = y + self.camera.y
            local cellData = self.state:get({x = mapX, y = mapY})
            if cellData then
                self:drawCellHighlight(x, y, mapX, mapY)
                self:drawItem(cellData, x, y)
            end
        end
    end
end

function Board:drawItem(obj, x, y)
    local cell = self.grid.storage[x][y]
    if not cell then return end

    if obj.type == "text" then
        love.graphics.print(obj.val, math.floor(self.bX + cell.tx), math.floor(self.bY + cell.cy))
    elseif self.sprites[obj.type] then
        local img = self.sprites[obj.type]
        love.graphics.draw(img, math.floor(self.bX + cell.cx), math.floor(self.bY + cell.cy), 0, 1, 1, math.floor(img:getWidth()/2), math.floor(img:getHeight()/2))
    end
end

function Board:drawCellHighlight(sx, sy, wx, wy)
    local cell = self.state:get({x = wx, y = wy})
    local isHovered = (wx == Mouse.hover.x and wy == Mouse.hover.y)

    if (cell and cell.active) or isHovered then
        local dX = math.floor(self.bX + (sx - 1) * self.squareSize)
        local dY = math.floor(self.bY + (sy - 1) * self.squareSize)

        -- Clear decision logic
        local r, g, b, a = 0.2, 0.6, 1, 0.5 -- Default: Active Blue
        if isHovered and not (cell and cell.active) then
            r, g, b, a = 1, 1, 1, 0.2      -- Hover only (White)
        elseif isHovered and (cell and cell.active) then
            r, g, b, a = 0.5, 0.8, 1, 0.8  -- Hover over Active (Bright)
        end

        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", dX, dY, self.squareSize, self.squareSize)
        love.graphics.setColor(1, 1, 1, 1) -- Reset
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
    local maxCamX = GRID_COUNT - VIEW_W
    local maxCamY = GRID_COUNT - VIEW_H
    self.camera.x = math.max(0, math.min(self.camera.x + dx, maxCamX))
    self.camera.y = math.max(0, math.min(self.camera.y + dy, maxCamY))
end
