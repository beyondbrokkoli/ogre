-- repository.lua
STATE = { grid = {} }
DEBUG_MODE = true

local debug_mt = {
    __tostring = function(t)
        return string.format("DEBUG: [type=%s, active=%s, last_mod=%s]",
               t.type, tostring(t.active), os.date("%H:%M:%S"))
    end
}

-- Initialize the repo structure to avoid nil index errors
function Data_Init(w, h)
    for x = 1, w do
        STATE.grid[x] = {}
        for y = 1, h do
            -- Crucially, we create a FRESH table here every time
            Data_Set(x, y, { type = "empty", active = false })
        end
    end
end

function Data_Get(x, y)
    -- Safe boundary access
    if STATE.grid[x] and STATE.grid[x][y] then
        return STATE.grid[x][y]
    end
    return nil
end

function Data_Set(x, y, val)
    STATE.grid[x][y] = val
    if DEBUG_MODE then
        setmetatable(val, debug_mt)
    end
end
