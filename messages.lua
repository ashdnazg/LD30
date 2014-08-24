local lume = require "lume"
local boats = require "boats"

function generate_intro()
    return {text = "You are the Ferryman, delivering the souls over the river Styx.\n" ..
                   "You gain gold by making sure souls reach the afterlife, until the game's end in " .. math.abs(G.start_year + G.num_years) .. (((G.start_year + G.num_years) >= 0) and " AD" or " BC")  .. ".\n" ..
                   "Use the menu below to buy new boats and read incoming messages.\n\n" ..
                   "Good Luck!",
            can_decline_fn = lume.lambda("-> false"),}
end

function generate_storm()
    local num_boats = math.ceil(lume.random(2))
    return {text = "River Styx stormy waters has claimed " .. num_boats .. " of your boats",
            accept_fn = function() for i=1,num_boats do boats.storm() end end,
            can_decline_fn = lume.lambda("-> false"),}
end

function generate_protection()
    local gold = math.ceil(lume.random(10)) * 5
    return {text = "A group of viciously looking demons arrived, claiming \"Styx can be a bery dangerous place\" and offering to guard your safety for a mere ".. gold .. " gold.",
            can_accept_fn = lume.lambda ("-> G.money >= " .. gold),
            accept_fn = function() G.money, G.demon_risk = G.money - gold, false end,
            decline_fn = function() G.demon_risk =  G.demon_length end}
end

function generate_insurance()
    local gold_each = math.ceil(lume.random(5))
    local total = G.number_of_boats * gold_each
    return {text = "A small man in a small suit had offered to insure your boats for " .. gold_each .. " gold each (total: " .. total ..").",
            can_accept_fn = lume.lambda ("-> G.money >= " .. total),
            accept_fn = function() G.money, G.insurance = G.money - total, G.insurance_length end,
            decline_fn = function() G.insurance = false end}
end

function generate_uncle()
    local num_boats = math.ceil(lume.random(3))
    return {text = "A rich uncle passed away and left you " .. num_boats .. " small boat" .. (num_boats > 1 and "s" or "") .. " in his will.",
            accept_fn = function() for i=1,num_boats do boats.add_boat("initial") end end,
            can_decline_fn = lume.lambda("-> false"),}
end

function generate_quit()
    return {text = "Game ended!" ..
                   "\n\nSouls saved: " .. G.people_saved ..
                   "\nSouls lost: " .. G.people_lost ..
                   "\nRemaining gold: " .. G.money ..
                   "\n\nTotal Score: " .. (G.money - G.people_lost * 5) ..
                   "\n\nThanks for playing! Do you want to play again?",
            accept_fn = function() G.restart = true end,
            decline_fn = function() love.event.quit() end}
end

local messages = { protection = generate_protection,
                   insurance = generate_insurance,
                   uncle = generate_uncle,
                   quit = generate_quit,
                   intro = generate_intro,
                   storm = generate_storm
                 }
                 
return messages