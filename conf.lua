function love.conf(t)
  if love._version ~= "0.8.0" then
    t.screen = t.window
  end

  t.screen.width = 640
  t.screen.height = 480
  t.screen.vsync = true
  t.identity = "LD30 ashdnazg"
  t.title = t.identity

  G = {}
  G.tile_size = 32
  G.land_width = 3
  
  G.width = t.screen.width
  G.height = t.screen.height
  G.width_tiles = G.width / G.tile_size
  G.height_tiles = G.height / G.tile_size
end
