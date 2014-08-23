local Entity = require "Entity"
local coil = require "coil"
local lume = require "lume"
local flux = require "flux"


local boats = {}

local BOAT_TYPES = {
        initial = {"initial.png", 48, 32, 50}
    }

local boat_list = {}


function boats.add_boat(boat_type)
    
    local b = {e = Entity(BOAT_TYPES[boat_type][1], BOAT_TYPES[boat_type][2], BOAT_TYPES[boat_type][3], BOAT_TYPES[boat_type][4]),
               threads = coil.group()}
    b.e.x = G.width / 2
    b.e.y = G.height / 2
    table.insert(boat_list, b)
end

function boats.load()
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
                if boat.anim then
                    boat.threads:remove(boat.anim)
                end
            end
            if not boat.stopping then
                boat.target = {lume.random(100,540), lume.random(100,380)}
                local ratio = (boat.target[1] - boat.e.x) / (boat.target[2] - boat.e.y)
                local sign = (boat.target[1] - boat.e.x) > 0 and 1 or -1
                local temp_vx = math.sqrt(boat.e.vmax * boat.e.vmax * (1 + ratio * ratio)) * sign
                flux.to(boat.e, 0.5, { vx = temp_vx , vy = temp_vx / ratio})
                    :ease("quadin")
                    boat.anim = boat.threads:add(
                        function()
                            repeat
                                boat.e.quad = (boat.e.quad % #boat.e.quads) + 1
                                coil.wait(0.2)
                            until nil
                        end)
                        
                if sign > 0 then
                    boat.e.flip = false
                else
                    boat.e.flip = true
                end
            end
        else
            local dist_sq = (boat.target[1] - boat.e.x) * (boat.target[1] - boat.e.x) + (boat.target[2] - boat.e.y) * (boat.target[2] - boat.e.y)
            if dist_sq < boat.e.vmax / 2 then
                boat.target = nil
            end
        end
        boat.e:update(dt)
        boat.threads:update(dt)
    end
end


return boats