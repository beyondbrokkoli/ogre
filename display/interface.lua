-- display/interface.lua (The "Future-Proof" version)
function Layout(w, h)
    local sidebarWidth = 0
    return {
        sizeW = w - sidebarWidth, -- The board only gets the remaining width
        sizeH = h,
        ox = sidebarWidth,        -- The board starts 200px in from the left
        oy = 0
    }
end
