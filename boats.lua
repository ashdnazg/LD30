local Entity = require "Entity"

local boats = {}

local boat_list = {}

function boats.load()

    local first_boat = {e = Entity("boat1.png", 48, 32)}
    table.insert(boat_list, first_boat)
end

function boats.draw()
    for _, boat in pairs(boat_list) do
        boat.e:draw()
    end
end


return boats