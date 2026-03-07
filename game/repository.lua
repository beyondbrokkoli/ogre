-- repository.lua (Revised, keeping DEBUG_MODE intact)
STATE = { grids = {} }
DEBUG_MODE = true

local debug_mt = {
    __tostring = function(t)
        return string.format("DEBUG: [type=%s, active=%s, last_mod=%s]",
               t.type, tostring(t.active), os.date("%H:%M:%S"))
    end
}

-- repository.lua (Revised)
STATE = { grids = {} }

-- Initialize a specific named grid
function Data_Init(name, w, h)
    STATE.grids[name] = {}
    for x = 1, w do
        STATE.grids[name][x] = {}
        for y = 1, h do
            Data_Set(name, x, y, { type = "empty", active = false })
        end
    end
end

-- Pass the 'name' to get/set
function Data_Get(name, x, y)
    return STATE.grids[name] and STATE.grids[name][x] and STATE.grids[name][x][y]
end

function Data_Set(name, x, y, val)
    STATE.grids[name][x][y] = val
    if DEBUG_MODE then setmetatable(val, debug_mt) end
end
