local map = require "map"


function love.draw()
    map.draw()
    love.graphics.print("Hello World", 320, 240)
end

function love.load()
    map.load()
end
 
function love.update(dt)
 
end