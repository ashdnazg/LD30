local map = require "map"
local boats = require "boats"
local people = require "people"
local flux = require "flux"
local menu = require "menu"
local timers = require "timers"

local music

function love.draw()
    love.graphics.translate(0, G.bar_height)
    map.draw()
    people.draw()
    boats.draw()
    menu.draw()
    
    if G.debug then
        love.graphics.print("Debug: " .. G.debug_str, 0, 0)
    end
end

function love.load()
    math.randomseed(os.time()) 
    map.load()
    boats.load()
    people.load()
    menu.load()
    music = love.audio.newSource("music.ogg")
    music:setLooping(true)
    music:play()
    timers.load()
end
 
function love.update(dt)
    G.debug_str = ""
    if not G.paused then
        flux.update(dt)
        boats.update(dt)
        people.update(dt)
        timers.update(dt)
    end
    menu.update(dt)
end

function love.mousepressed(x, y, button)
    menu.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    menu.mousereleased(x, y, button)
end