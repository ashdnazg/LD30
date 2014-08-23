local map = require "map"
local boats = require "boats"
local people = require "people"
local flux = require "flux"

function love.draw()
    map.draw()
    people.draw()
    boats.draw()
end

function love.load()
    map.load()
    boats.load()
end
 
function love.update(dt)
    flux.update(dt)
    boats.update(dt)
    people.update(dt)
end