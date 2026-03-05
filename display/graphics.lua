require("global")

-- One mapper to rule them all.
function GridMap(square)
    local m = Map:new(GRID_WIDTH, GRID_HEIGHT)
    local half = square / 2
    for x = 1, GRID_WIDTH do
        for y = 1, GRID_HEIGHT do
            m[x][y] = {
                -- Pre-calculated anchors
                cx = (x - 1) * square + half, -- Center X
                cy = (y - 1) * square + half, -- Center Y
                tx = (x - 1) * square + 4,    -- Top-left (with 4px padding) for Font
            }
        end
    end
    return m
end
