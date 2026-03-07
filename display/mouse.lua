-- added initialization necessary, now properly initializing hover
Mouse = {
    hover = {x = 0, y = 0} -- Initialize the table here!
}

function Mouse:update(board)
    local mx, my = love.mouse.getPosition()
    local sx, sy = board:screenToGrid(mx, my) -- Get the screen slot
    local wx, wy = board:toWorld(sx, sy)     -- Map it to the world data

    if wx then
        self.hover.x, self.hover.y = wx, wy
    else
        self.hover.x, self.hover.y = nil, nil
    end
end

function Mouse:pressed(board, x, y, button)
    if button == 1 then
        local sx, sy = board:screenToGrid(x, y)
        local wx, wy = board:toWorld(sx, sy)

        if wx then
            -- 1. Get the current state via Handle
            local cell = board.state:get({x = wx, y = wy})

            -- 2. Toggle the property
            cell.active = not cell.active

            -- 3. Push the update back to the Repository
            board.state:set({x = wx, y = wy}, cell)
        end
    end
end
