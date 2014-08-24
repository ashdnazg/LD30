local coil = require "coil"
local history = require "history"
local people = require "people"
local menu = require "menu"
local lume = require "lume"

local timers = {}
local threads


function tick()
    repeat
        G.year = G.year + 1
        local event = history[G.year] or history.default
        if not event.chance or lume.random(event.chance) < 1 then
            for people_type, num in pairs(event.spawns) do
                people.add_people(people_type, num)
            end
        end
        if event.headline then
            menu.set_headline(event.headline)
        end
        coil.wait(1)
    until nil
end

function timers.load()
    threads = coil.group()
    threads:add(tick)
end

function timers.update(dt)
    threads:update(dt)
end

return timers