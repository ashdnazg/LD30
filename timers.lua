local coil = require "coil"
local history = require "history"
local people = require "people"
local menu = require "menu"
local lume = require "lume"
local messages = require "messages"
local boats = require "boats"

local timers = {}
local threads

function get_message()
    if (not G.insurance or G.insurance < 0) and lume.random(G.message_chance) < 1 then
        return messages.insurance()
    end
    if (not G.demon_risk or G.demon_risk < 0) and lume.random(G.message_chance) < 1 then
        return messages.protection()
    end
    if (G.number_of_boats > 2 and lume.random(G.message_chance) < 1) then
        return messages.storm()
    end
    if (G.number_of_boats < 5 and lume.random(G.message_chance) < 1) then
        return messages.uncle()
    end
    if (G.number_of_boats > 5 and lume.random(G.message_chance) < 1) then
        return messages.permit()
    end
    return nil
end

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
        if G.insurance then
            G.insurance = G.insurance - 1
            if G.insurance < 0 then
                G.insurance = false
            end
        end
        if G.demon_risk then
            G.demon_risk = G.demon_risk - 1
            if G.demon_risk < 0 then
                G.demon_risk = false
            end
        end

        local message = get_message()
        if message then
            menu.set_message(message)
        end
        if G.year == G.start_year + G.num_years then
            G.quit = true
        end
        if G.demon_risk then 
            if lume.random(20 - G.number_of_boats) < 1 then
                boats.create_trident()
            end
        end
        coil.wait(G.timer_delay)
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