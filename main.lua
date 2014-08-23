local map = require "map"
local boats = require "boats"
local people = require "people"
local flux = require "flux"

function love.draw()
    map.draw()
    people.draw()
    boats.draw()
    if G.debug then
        love.graphics.print("Debug: " .. G.debug_str, 0, 0)
    end
end

function love.load()
    math.randomseed(os.time()) 
    map.load()
    boats.load()
    people.load()
end
 
function love.update(dt)
    flux.update(dt)
    boats.update(dt)
    people.update(dt)
end