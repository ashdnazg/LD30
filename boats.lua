local Entity = require "Entity"
local coil = require "coil"
local lume = require "lume"
local flux = require "flux"
local people = require "people"


local boats = {}

local boat_list

local BOAT_TYPES = {
        initial = {"initial.png", 48, 32, 150, 1}
    }


function boats.add_boat(boat_type)
    
    local b = {e = Entity(BOAT_TYPES[boat_type][1], BOAT_TYPES[boat_type][2], BOAT_TYPES[boat_type][3], BOAT_TYPES[boat_type][4]),
               threads = coil.group(), cost = G.boat_prices[boat_type], capacity = BOAT_TYPES[boat_type][5], passengers = {}}
    b.e.x = lume.random(G.width / 2 - b.e.w, G.width / 2 + b.e.w)
    b.e.y = lume.random(G.height / 2 - b.e.w, G.height / 2 + b.e.w)
    table.insert(boat_list, b)
    G.number_of_boats = G.number_of_boats + 1
end

function boats.remove_boat(id)
    if not boat_list[id] then return end
    
    if G.insurance then
        G.money = G.money + boat_list[id].cost
    end
    G.number_of_boats = G.number_of_boats - 1
    if boat_list[id].p_target then
        boat_list[id].p_target.due = false
    end
    if boat_list[id].passengers then
        for _, person in pairs(boat_list[id].passengers) do
            people.remove_person(person)
        end
    end
    table.remove(boat_list, id)
end


function boats.load()
    boat_list = {}
    boats.add_boat("initial")
end

function boats.draw()
    for _, boat in pairs(boat_list) do
        boat.e:draw()
    end
end


function boats.update(dt)
    for _, boat in pairs(boat_list) do
        if not boat.target then
        
            if not boat.stopping and boat.e.vx ~= 0 then
                flux.to(boat.e, 0.5, { vx = 0, vy = 0})
                    :ease("quadout")
                boat.stopping = true
            elseif boat.e.vx == 0 then
                boat.stopping = false
                boat.e.quad = 1
                if boat.p_target then
                    table.insert(boat.passengers, boat.p_target)
                    boat.p_target.due = false
                    boat.p_target.delivered = true
                    boat.p_target = nil
                else
                    if boat.passengers then
                        for _, passenger in pairs (boat.passengers) do
                            passenger.e.x = lume.random(passenger.e.w, passenger.e.x - boat.e.w)
                            passenger.e.y = lume.random(passenger.e.y - 5, passenger.e.y + 5)
                            people.kill(passenger)
                        end
                        boat.passengers = {}
                    end
                end
                if boat.anim then
                    boat.threads:remove(boat.anim)
                end
            end
            if not boat.stopping then
                local ratio, sign , temp_vx
                local p_target = people.get_next()
                if #boat.passengers == boat.capacity or (not p_target and #boat.passengers > 0) then
                    boat.target = {G.land_width * G.tile_size + boat.e.w, boat.e.y}
                    sign = -1
                    temp_vx = - boat.e.vmax
                else
                    if p_target then
                        boat.p_target = p_target
                        p_target.due = true
                        p_target.incoming_boat = boat
                        boat.target = {G.width - G.land_width * G.tile_size - boat.e.w, p_target.e.y}
                        ratio = (boat.target[1] - boat.e.x) / (boat.target[2] - boat.e.y)
                        sign = (boat.target[1] - boat.e.x) > 0 and 1 or -1
                        temp_vx = math.sqrt(boat.e.vmax * boat.e.vmax * (1 + ratio * ratio)) * sign
                    end
                end
                if boat.target then
                    flux.to(boat.e, 0.5, { vx = temp_vx , vy = ratio and (temp_vx / ratio) or 0})
                        :ease("quadin")
                        boat.anim = boat.threads:add(
                            function()
                                repeat
                                    boat.e.quad = (boat.e.quad % #boat.e.quads) + 1
                                    coil.wait(0.15)
                                until nil
                            end)
                            
                    if sign > 0 then
                        boat.e.flip = false
                    else
                        boat.e.flip = true
                    end
                end
            end
        else
            local dist_sq = (boat.target[1] - boat.e.x) * (boat.target[1] - boat.e.x) + (boat.target[2] - boat.e.y) * (boat.target[2] - boat.e.y)
            if dist_sq < boat.e.vmax / 2 then
                boat.target = nil
                -- if boat.p_target then
                    -- if boat.passengers then
                        -- boat.p_target = nil
                        -- boat.passengers = nil
                    -- else
                        -- boat.p_target.due = false
                        -- boat.p_target.delivered = true
                    -- end
                -- end
            end
        end
        if boat.passengers then
            local offset = 0
            for _, passenger in pairs (boat.passengers) do
                passenger.e.x = boat.e.x + passenger.e.w / 2 - offset
                passenger.e.y = boat.e.y - passenger.e.h / 2
                offset = offset + 12
            end
        end
        boat.e:update(dt)
        boat.threads:update(dt)
    end
end


return boats