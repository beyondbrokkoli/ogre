-- The "Industrial" persistent vector
local target_buf = {x=0, y=0}

function visionM(pos, l, dir)
    local current = {x=l.x, y=l.y} -- Current square
    local m = {}

    while true do
        -- Use the industrial moveFast
        if not loc.moveFast(current, dir, target_buf) then break end

        -- Copy values to a new object only when a valid move is found
        local s = loc:new(target_buf.x, target_buf.y)

        if pos[s] == 0 then
            table.insert(m, s)
            current.x, current.y = s.x, s.y
        elseif opponents(id, pos[s]) then
            table.insert(m, s)
            break
        else
            break
        end
    end
    return m
end
