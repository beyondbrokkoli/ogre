require("display/graphics")
-- make UI_FONT a global variable
UI_FONT = love.graphics.newFont(12)
-- Industrial Grade Display Engine
GRID_COUNT = 8
-- In global.lua or a dedicated "calc" module
CALC_BUF = {x=0, y=0}

-- Directions: Top-Left Origin (x=0, y=0 is top-left)
-- Compass: 1=Down (+y), 3=Right (+x), 5=Up (-y), 7=Left (-x)
-- Knight: L-shaped moves starting from Down-Right quadrant
local DIRS = {
    -- Compass (Primary Axes + Diagonals)
    [1] = {x= 0, y= 1},   -- DOWN (y increases)
    [2] = {x= 1, y= 1},   -- DOWN-RIGHT
    [3] = {x= 1, y= 0},   -- RIGHT (x increases)
    [4] = {x= 1, y=-1},   -- UP-RIGHT
    [5] = {x= 0, y=-1},   -- UP (y decreases)
    [6] = {x=-1, y=-1},   -- UP-LEFT
    [7] = {x=-1, y= 0},   -- LEFT (x decreases)
    [8] = {x=-1, y= 1},   -- DOWN-LEFT

    -- Knight Moves (L-shape: 2 units one way, 1 perpendicular)
    [9]  = {x= 1, y= 2},  -- Down 2, Right 1
    [10] = {x= 2, y= 1},  -- Down 1, Right 2
    [11] = {x= 2, y=-1},  -- Up 1, Right 2
    [12] = {x= 1, y=-2},  -- Up 2, Right 1
    [13] = {x=-1, y=-2},  -- Up 2, Left 1
    [14] = {x=-2, y=-1},  -- Up 1, Left 2
    [15] = {x=-2, y= 1},  -- Down 1, Left 2
    [16] = {x=-1, y= 2},  -- Down 2, Left 1
}

-- 1. The Location Class
loc = {}
function loc:new(x, y)
    local l = {x = x, y = y}
    return l

end

-- Updated optimized move method
function loc:moveFast(dir, target)
    local d = DIRS[dir] -- Using your pre-calculated direction table
    if not d then return false end

    local nx, ny = self.x + d.x, self.y + d.y
    -- Using a raw check (non-object) to prevent allocation
    if nx >= 1 and ny >= 1 and nx <= GRID_COUNT and ny <= GRID_COUNT then
        target.x = nx
        target.y = ny
        return true
    end
    return false
end

-- 2. The Updated Map Class
Map = {}
-- Refactored Map:new
function Map:new(w, h, insert)
    -- Instead of creating 'self.storage', we ensure the repository is ready
    Data_Init(w, h)
    -- Return an empty object (no need to store anything)
    return setmetatable({}, {__index = Map})
end

-- Refactored Map:get
function Map:get(loc)
    return Data_Get(loc.x, loc.y)
end

-- Refactored Map:set
function Map:set(loc, val)
    Data_Set(loc.x, loc.y, val)
end

function vision(map, l, dir, callback)
    local current = {x=l.x, y=l.y}
    while true do
        -- map passes the responsibility of the move check to the caller
        -- using the pre-allocated CALC_BUF to avoid garbage
        if not loc.moveFast(current, dir, CALC_BUF) then break end

        -- The callback now receives the coords directly from the buffer
        if not callback(CALC_BUF.x, CALC_BUF.y) then break end

        current.x, current.y = CALC_BUF.x, CALC_BUF.y
    end
end

function doAcross(w, h, pos, f)
    for x = 1, w do
        for y = 1, h do
            f(pos[x][y], x, y)
        end
    end
end

-- The Pathfinder loop (Fast)
function FindPath(start_x, start_y, direction)
    local current = loc:new(start_x, start_y)

    -- Fast Path: Move around using the 'loc' math logic
    if current:moveFast(direction, CALC_BUF) then

        -- Safe Path: Only when we land, we ask the Repository
        local cell = Data_Get(CALC_BUF.x, CALC_BUF.y)

        if cell and cell.type ~= "wall" then
            return true -- Valid move!
        end
    end
    return false
end
