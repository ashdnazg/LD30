local lume = require "lume"


local Entity = {}
Entity.__index = Entity

setmetatable(Entity, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Entity.new(spritesheet_path, sprite_w, sprite_h, vmax)
    local sprites = love.graphics.newImage(spritesheet_path)
    local quads = {}
    local width, height = sprites:getWidth(), sprites:getHeight()
    
    
    for i = 1, width / sprite_w do
        for j = 1, height / sprite_h do
            table.insert(quads, love.graphics.newQuad((i - 1) * sprite_w,  (j - 1) * sprite_h, sprite_w, sprite_h, width, height))
        end
    end
    
    local e = {x = 0,
               y = 0,
               vx = 0,
               vy = 0,
               ax = 0,
               ay = 0,
               ["vmax"] = vmax,
               ["sprites"] = sprites,
               quad = 1,
               ["quads"] = quads,
               w = sprite_w,
               h = sprite_h,
               opacity = 255,
               flip = false}
    setmetatable(e, Entity)
    return e
end

function Entity:draw()
    love.graphics.setColor( self.opacity,self.opacity,self.opacity, self.opacity)
    love.graphics.draw(self.sprites, self.quads[self.quad], lume.round(self.x),  lume.round(self.y), 0, self.flip and -1 or 1, 1, self.w / 2, self.h / 2)
    love.graphics.setColor( 255,255,255, 255)
end

function Entity:update(dt)
    self.vx = self.vx + self.ax * dt
    self.vy = self.vy + self.ay * dt
    local v_squared = self.vx * self.vx + self.vy * self.vy
    local vmax_squared = self.vmax * self.vmax
    if  v_squared > vmax_squared then
        local ratio = math.sqrt(vmax_squared/ v_squared)
        self.vx = self.vx * ratio
        self.vy = self.vy * ratio
    end
    
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
end

return Entity