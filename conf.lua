local GAME_WIDTH = 640
local GAME_HEIGHT = 480
local MENU_HEIGHT = 64
local BAR_HEIGHT = 32

function love.conf(t)
  if love._version ~= "0.8.0" then
    t.screen = t.window
  end
  
  
  t.screen.width = GAME_WIDTH
  t.screen.height = GAME_HEIGHT + BAR_HEIGHT + MENU_HEIGHT
  t.screen.vsync = true
  t.identity = "LD30 ashdnazg"
  t.title = t.identity

  G = {}
  G.tile_size = 32
  G.land_width = 3
  G.debug = false
  
  G.paused = false
  G.debug_str = "None"
  G.width = GAME_WIDTH
  G.height = GAME_HEIGHT
  G.width_tiles = G.width / G.tile_size
  G.height_tiles = G.height / G.tile_size
  G.bar_height = BAR_HEIGHT
  G.menu_height = MENU_HEIGHT
  G.boat_prices = { initial = 5, whale = 15, titanic = 25}
  G.money_increment = 2
  G.start_year = -300
  G.num_years = 200
  G.insurance_length = 50
  G.demon_length = 20
  G.message_chance = 50
  G.timer_delay = 1
end
