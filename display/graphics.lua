-- graphics.lua (new)
function GridMap(width, height, square)
    local m = Map:new(width, height)
    local half = math.floor(square / 2) -- Snap to integer
    for x = 1, width do
        for y = 1, height do
            m.storage[x][y] = {
                -- Force integers: no more sub-pixel bleeding
                cx = math.floor((x - 1) * square) + half,
                cy = math.floor((y - 1) * square) + half,
                tx = math.floor((x - 1) * square) + 4
            }
        end
    end
    return m
end
