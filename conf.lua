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
  G.land_width = 7
  G.debug = true
  
  G.paused = false
  G.debug_str = "None"
  G.width = GAME_WIDTH
  G.height = GAME_HEIGHT
  G.width_tiles = G.width / G.tile_size
  G.height_tiles = G.height / G.tile_size
  G.bar_height = BAR_HEIGHT
  G.menu_height = MENU_HEIGHT
  G.boat_prices = { initial = 10 }
  
  G.money = 0
end
