-- game/setup.lua
function AuditData(data, path)
    for k, v in pairs(data) do
        if type(v) == "table" then
            AuditData(v, path .. "." .. k)
        elseif k == "x" or k == "y" then
            -- Verify coordinates fall within GRID_COUNT
            if v < 1 or v > GRID_COUNT then
                error("Invalid coordinate at: " .. path .. "." .. k)
            end
        end
    end
end
