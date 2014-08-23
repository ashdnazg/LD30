local Entity = {}
Entity.__index = Entity

setmetatable(Entity, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Entity.new(spritesheet_path, sprite_w, sprite_h)
    local sprites = love.graphics.newImage(spritesheet_path)
    local quads = {}
    local width, height = sprites:getWidth(), sprites:getHeight()
    
    
    for i = 1, width / G.tile_size do
        for j = 1, height / G.tile_size do
            table.insert(quads, love.graphics.newQuad((i - 1) * G.tile_size,  (j - 1) * G.tile_size, sprite_w, sprite_h, width, height))
        end
    end
    
    local e = {x = 0,
               y = 0,
               vx = 0,
               vy = 0,
               ax = 0,
               ay = 0,
               ["sprites"] = sprites,
               quad = 1,
               ["quads"] = quads}
    setmetatable(e, Entity)
    return e
end

function Entity:draw()
   love.graphics.draw(self.sprites, self.quads[self.quad], self.x,  self.y) 
end


return Entity