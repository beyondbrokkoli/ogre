-- display/graphics.lua
function GridMap(width, height, square)
    local m = { storage = {} } -- Simple table, not a Map handle
    local half = math.floor(square / 2)
    for x = 1, width do
        m.storage[x] = {} -- Initialize the column!
        for y = 1, height do
            m.storage[x][y] = {
                cx = math.floor((x - 1) * square) + half,
                cy = math.floor((y - 1) * square) + half,
                tx = math.floor((x - 1) * square) + 4
            }
        end
    end
    return m
end
