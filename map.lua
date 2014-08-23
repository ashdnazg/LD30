local map = {}
local tile_set
local tile_quads
local quad_index = {["G"] = 1,
                    ["L"] = 2, 
                    ["W"] = 3,
                    ["R"] = 4 }

local tile_map

function load_tiles()
    tile_set = love.graphics.newImage('tiles.png')
    tile_quads = {}
    local width, height = tile_set:getWidth(), tile_set:getHeight()
    
    
    for i = 1, width / G.tile_size do
        for j = 1, height / G.tile_size do
            table.insert(tile_quads, love.graphics.newQuad((i - 1) * G.tile_size,  (j - 1) * G.tile_size, G.tile_size, G.tile_size, width, height))
        end
    end
end


function map.draw()
    for i = 1, G.width_tiles do
        for j = 1, G.height_tiles do
            love.graphics.draw(tile_set, tile_quads[quad_index[tile_map[i][j]]], (i - 1) * G.tile_size,  (j - 1) * G.tile_size)
        end
    end
end

function map.load()
    load_tiles()
    tile_map = {}
    for i = 1, G.width_tiles do
        local tile_col = {}
        for j = 1, G.height_tiles do
            local quad_type = "G"
            if i <= G.land_width or i > G.width_tiles - G.land_width then
                quad_type = "G"
            elseif i == G.land_width + 1 then
                quad_type = "L"
            elseif i == G.width_tiles - G.land_width then
                quad_type = "R"
            else
                quad_type = "W"
            end
            table.insert(tile_col, quad_type)
        end
        table.insert(tile_map, tile_col)
    end
end

return map