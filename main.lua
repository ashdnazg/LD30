local map = require "map"
local boats = require "boats"


function love.draw()
    map.draw()
    boats.draw()
    love.graphics.print("Hello World", 320, 240)
end

function love.load()
    map.load()
    boats.load()
end
 
function love.update(dt)
 
end