function Game()
    local g = { state = {} }

    function g:set(x, y, spriteName)
        if not g.state[x] then g.state[x] = {} end
        g.state[x][y] = spriteName
    end

    function g:get(x, y)
        return g.state[x] and g.state[x][y]
    end

    return g
end
