GRID_WIDTH = 8
GRID_HEIGHT = 8
GRID_COUNT = 8
function outside(t)
    return t.x < 1 or t.y < 1 or t.x > GRID_WIDTH or t.y > GRID_HEIGHT
end

-- Directions: Top-Left Origin
-- 1-8: Compass (Clockwise from Down)
-- 9-16: Knight Moves (Clockwise from "Long Down, Right 1")
local DIRS = {
    -- Compass
    [1] = {x= 0, y= 1},  -- DOWN
    [2] = {x= 1, y= 1},  -- DOWN-RIGHT
    [3] = {x= 1, y= 0},  -- RIGHT
    [4] = {x= 1, y=-1},  -- UP-RIGHT
    [5] = {x= 0, y=-1},  -- UP
    [6] = {x=-1, y=-1},  -- UP-LEFT
    [7] = {x=-1, y= 0},  -- LEFT
    [8] = {x=-1, y= 1},  -- DOWN-LEFT

    -- Knights (Clockwise rotation)
    [9]  = {x= 1, y= 2},  -- 2 Down, 1 Right
    [10] = {x= 2, y= 1},  -- 1 Down, 2 Right
    [11] = {x= 2, y=-1},  -- 1 Up, 2 Right
    [12] = {x= 1, y=-2},  -- 2 Up, 1 Right
    [13] = {x=-1, y=-2},  -- 2 Up, 1 Left
    [14] = {x=-2, y=-1},  -- 1 Up, 2 Left
    [15] = {x=-2, y= 1},  -- 1 Down, 2 Left
    [16] = {x=-1, y= 2},  -- 2 Down, 1 Left
}

-- 1. The Location Class
loc = {}
function loc:new(x, y)
    local l = {x = x, y = y}
    setmetatable(l, {
        __index = loc,
        __add = function(one, two) return loc:new(one.x + two.x, one.y + two.y) end,
        __eq = function(one, two) return one.x == two.x and one.y == two.y end
    })

-- commenting this out for clarity
--    function l:moveSlow(dir)
--        local new = self:v(dir)
--        return not outside(new) and new or false
--    end

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
function Map:new(w, h, insert)
    local m = { storage = {} }
    setmetatable(m, {
        __index = function(t, k)
            if type(k) == "table" then return t.storage[k.x][k.y] end
            return t.storage[k]
        end,
        __newindex = function(t, k, v)
            if type(k) == "table" then t.storage[k.x][k.y] = v
            else t.storage[k] = v end
        end
    })
    for i = 1, (w or GRID_WIDTH) do
        m.storage[i] = {}
        for j = 1, (h or GRID_HEIGHT) do
            -- Ensure each cell gets its own table instance if insert is a table
            m.storage[i][j] = (type(insert) == "table") and {} or insert
        end
    end
    return m
end

function do8x8(pos, f)
    for x = 1, 8 do
        for y = 1, 8 do
            f(pos[x][y], x, y)
        end
    end
end
