local flux = require "flux"
local lume = require "lume"
local boats = require "boats"

local menu = {}
local buttons
local menu_size
local tweens = flux.group()


function buy_boat(boat_type)
    if G.money >= G.boat_prices[boat_type] then
        G.money = G.money -  G.boat_prices[boat_type]
        boats.add_boat(boat_type)
    end
end

function menu.draw()
    for i = 1, menu_size do
        local button = buttons[i]
        local img
        if button then
            if not button.state then
                img = button.img_disabled
            elseif button.pressed then
                img = button.img_pressed
            else
                img = button.img
            end
        else
            img = buttons.empty.img
        end
        love.graphics.draw(img, G.menu_height * (i-1), G.height)
        
    end
end

function menu.load()
    buttons = { {name = "initialbtn", 
                 state_fn = lume.lambda"-> G.money >= G.boat_prices.initial",
                 click_fn = lume.fn(buy_boat, "initial")},
                empty = {name = "empty"}
              }
    
    menu_size = G.width / G.menu_height
    for i = 1,#buttons do
        local button = buttons[i]
        button.img = love.graphics.newImage(button.name .. ".png")
        button.img_disabled = love.graphics.newImage(button.name .. "_disabled.png")
        button.img_pressed = love.graphics.newImage(button.name .. "_pressed.png")
        button.pressed = false
    end
    buttons.empty.img = love.graphics.newImage("empty.png")
end

function menu.update(dt)
    G.debug_str = G.debug_str .. " Money: " .. G.money
    for i = 1, menu_size do
        local button = buttons[i]
        if button then
            button.pressed = false
            button.state = button.state_fn()
        end
    end
    if love.mouse.isDown("l") then
        local mx, my = love.mouse.getPosition()
        my = my - G.bar_height
        if my > G.height + 6 and my <= G.height + G.menu_height - 6 and
        (mx % G.menu_height) > 6 and (mx % G.menu_height) <= G.menu_height - 6 then
            local button = buttons[math.floor(mx / G.menu_height) + 1]
            if button and button.state then
                button.pressed = true
            end
        end
    end
    
    
    tweens:update(dt)
end

function menu.mousepressed(x, y, button)
end


function menu.mousereleased(x, y, button)
    G.debug_str = G.debug_str .. " click"
    for i = 1, menu_size do
        local button = buttons[i]
        if button and button.pressed then
            button.click_fn()
        end
    end
end

return menu