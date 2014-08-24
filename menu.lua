local flux = require "flux"
local lume = require "lume"
local boats = require "boats"
local messages = require "messages"

local menu = {}
local buttons
local menu_length
local button_size
local tweens
local message
local message_open
local message_img
local bar_img

local message_height
local message_width
local click_sound

local headline
local news_sound

function open_message()
    G.paused = true
    message_open = true
end

function can_accept_message()
    return message and (not message.can_accept_fn or message.can_accept_fn())
end

function can_decline_message()
    return message and (not message.can_decline_fn or message.can_decline_fn())
end

function close_message()
    G.paused = false
    message_open = false
    message = nil
end

function accept_message()
    if message.accept_fn then
       message.accept_fn() 
    end
    close_message()
end

function decline_message()
    if message.decline_fn then
       message.decline_fn() 
    end
    close_message()
end

function draw_message()
    love.graphics.draw(message_img, G.width / 2,  G.height / 2, 0, 1, 1, message_width / 2, message_height / 2)
    love.graphics.setColor(0,0,0)
    love.graphics.setNewFont(12)
    love.graphics.printf(message.text, 104, 108, 438, "left")
    love.graphics.setNewFont(12)
    love.graphics.setColor( 255,255,255, 255)
    local vimg, ximg
    vimg = get_button_img(buttons.v)
    ximg = get_button_img(buttons.x)
    love.graphics.draw(ximg, G.width / 4 + button_size, G.height / 2 + button_size, 0, 1, 1, button_size / 2, 0)
    love.graphics.draw(vimg, 3 * G.width / 4 - button_size, G.height / 2 + button_size, 0, 1, 1, button_size / 2, 0)
end


function buy_boat(boat_type)
    if G.money >= G.boat_prices[boat_type] then
        G.money = G.money -  G.boat_prices[boat_type]
        boats.add_boat(boat_type)
    end
end

function get_button_img(button)
    if not button.state then
        return button.img_disabled
    elseif button.pressed then
        return button.img_pressed
    else
        return button.img
    end
end

function menu.set_headline(text)
    headline = text
    news_sound:play()
end

function menu.set_message(msg)
    message = msg
end

function menu.draw()
    for i = 1, menu_length do
        local button = buttons[i]
        local img
        if button then
            img = get_button_img(button)
        else
            img = buttons.empty.img
        end
        love.graphics.draw(img, G.menu_height * (i-1), G.height)
    end
    
    if message_open then
        draw_message()
    end
    love.graphics.draw(bar_img, 0, -G.bar_height)
    love.graphics.setColor(0,0,0)
    love.graphics.setNewFont(24)
    love.graphics.print("Gold: " .. G.money, 4, -G.bar_height + 4, 0, 1, 1)
    local year_str = math.abs(G.year) .. ((G.year >= 0) and " AD" or " BC")
    love.graphics.printf("Year: " .. year_str,4, -G.bar_height + 4, G.width - 8, "right")
    love.graphics.setNewFont(12)
    if headline then
        love.graphics.printf("Breaking News: " .. headline, 126, -G.bar_height + 2, 333, "center")
    end
    love.graphics.setColor( 255,255,255, 255)
end

function has_message()
    return message
end

function menu.load()
    tweens = flux.group()
    buttons = { {name = "initialbtn", 
                 state_fn = lume.lambda"-> G.money >= G.boat_prices.initial",
                 click_fn = lume.fn(buy_boat, "initial")},
                {name = "messagebtn", 
                 state_fn = has_message,
                 click_fn = open_message},
                empty = {name = "empty"},
                v = {name = "vbtn",
                     state_fn = can_accept_message,
                     click_fn = accept_message},
                x = {name = "xbtn",
                     state_fn = can_decline_message,
                     click_fn = decline_message},
              }
    
    menu_length = G.width / G.menu_height
    for _, button in pairs(buttons) do
        button.img = love.graphics.newImage(button.name .. ".png")
        if button.state_fn then
            button.img_disabled = love.graphics.newImage(button.name .. "_disabled.png")
        end
        if button.click_fn then
            button.img_pressed = love.graphics.newImage(button.name .. "_pressed.png")
        end
        button.pressed = false
    end
    buttons.empty.img = love.graphics.newImage("empty.png")
    button_size = buttons.empty.img:getWidth()
    message_img = love.graphics.newImage("message.png")
    message_width, message_height = message_img:getWidth(), message_img:getHeight()
    bar_img = love.graphics.newImage("bar.png")
    
    
    click_sound = love.audio.newSource("click.ogg")
    news_sound = love.audio.newSource("news.ogg")
    
    
    message = messages.intro()
    message_open = true
    G.paused = true
end

function menu.update(dt)
    for id, button in pairs(buttons) do
        button.pressed = false
        if button.state_fn then
            button.state = not message_open and button.state_fn()
        end
    end
    if message_open then
        buttons.x.state = buttons.x.state_fn()
        buttons.v.state = buttons.v.state_fn()
        if love.mouse.isDown("l") then
            local mx, my = love.mouse.getPosition()
            my = my - G.bar_height
            if my > G.height / 2 + button_size + 6 and my <= G.height / 2 + button_size * 2 - 6 then
                local button
                if mx > 3 * G.width / 4 - 3 * button_size / 2 + 6 and mx <= 3 * G.width / 4 - button_size / 2 - 6 then
                    button = buttons.v
                elseif mx > G.width / 4 + button_size / 2 + 6 and mx <= G.width / 4 + 3 * button_size / 2 - 6 then
                    button = buttons.x
                end
                
                if button and button.state then
                    button.pressed = true
                end
            end
        end
    else
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
    end
    if G.quit then
        message = messages.quit()
        message_open = true
        G.paused = true
    end
    
    tweens:update(dt)
end

function menu.mousepressed(x, y, button)
end


function menu.mousereleased(x, y, button)
    G.debug_str = G.debug_str .. " click"
    for _, button in pairs(buttons) do
        if button.pressed then
            button.click_fn()
            click_sound:play()
        end
    end
end

return menu