local ResourceManager = require("engine.resource_manager")
local Background = {}
Background.__index = Background

function Background:new(id, time)
    local self = setmetatable({}, Background)
    self.id = id
    self.time = time
    self.image = ResourceManager.loadBackground(id, time)
    self.visible = false
    return self
end

function Background:changeTime(time)
    self.time = time
    self.image = ResourceManager.loadBackground(self.id, time)
end

function Background:draw()
    if self.visible and self.image then
        love.graphics.draw(self.image, 0, 0, 0, love.graphics.getWidth()/self.image:getWidth(), love.graphics.getHeight()/self.image:getHeight())
    end
end

return Background