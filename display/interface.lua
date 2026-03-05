function Layout(x, y, f)
    local size = math.min(x, y)
    local ox = math.floor((x - size) / 2 + 0.5)
    local oy = math.floor((y - size) / 2 + 0.5)
    return { size = size, ox = ox, oy = oy }
end
