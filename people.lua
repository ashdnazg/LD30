local Entity = require "Entity"
local flux = require "flux"
local lume = require "lume"
local people = {}

local PEOPLE_TYPES = {
        roman = {1, 24, 32},
        centurion = {4, 24, 32},
        ghost = {1, 24, 32}
    }

local people_list
local ghost_list
local lowest_existing

local coin_sound

function new_people(people_type)
    local img_name = people_type .. (math.floor(lume.random(PEOPLE_TYPES[people_type][1])) + 1) .. ".png"
    local p = {e = Entity(img_name, PEOPLE_TYPES[people_type][2], PEOPLE_TYPES[people_type][3], 1000),
                   year = 0, due = false, aboard = false, delivered = false}
    return p
end

function people.add_people(people_type, num)
    local base_y = math.random(G.tile_size, G.height - G.tile_size)
    for i = 1, num do 
        local p = new_people(people_type)
        p.e.x = math.random(G.width - G.land_width * G.tile_size, G.width - G.tile_size)
        p.e.y = base_y + math.random(-G.tile_size, G.tile_size)
        p.e.opacity = 0
        flux.to(p.e, 0.3, { opacity = 255})
                        :ease("quadin"):delay(math.random(1,6) / 10)
        table.insert(people_list, p)
    end
end

function people.get_next()
    local reached_waiting = false
    for i = lowest_existing, #people_list do
        local p = people_list[i]
        if p then
            if p.delivered and not reached_waiting then
                lowest_existing = i + 1
            else
                reached_waiting = true
                if not p.delivered and not p.due then
                    return p
                end
            end
        end
    end
    return nil
end

function people.load()
   --people.add_people("roman", 30)
   people_list = {}
   ghost_list = {}
   coin_sound = love.audio.newSource("coins.ogg")
   lowest_existing = 1
end

function people.draw()
    for _, people in pairs(people_list) do
        people.e:draw()
    end
    for _, people in pairs(ghost_list) do
        people.e:draw()
    end
end

function people.update(dt)
    for _, people in pairs(people_list) do
        people.e:update(dt)
    end
    for i = 1, #ghost_list do
        local ghost = ghost_list[i]
        if ghost then
            ghost.e:update(dt)
            if ghost.e.y < 0 then
                table.remove(ghost_list, i)
            end
        end
    end
end

function people.remove_person(p)
    p.e.opacity = 0
    p.delivered = true
    G.people_lost = G.people_lost + 1
end

function people.kill(p)
    flux.to(p.e, 2, { opacity = 0})
                        :ease("quadout")
    local g = new_people("ghost")
    table.insert(ghost_list, g)
    g.e.x = p.e.x
    g.e.y = p.e.y
    g.e.opacity = 180
    flux.to(g.e, 1, { vy = -100})
                        :ease("quadin")
    G.money = G.money + G.money_increment
    coin_sound:clone():play()
    G.people_saved = G.people_saved + 1
end

return people