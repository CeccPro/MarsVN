local ResourceManager = require("engine.resource_manager")
local textBoxParams = dofile("assets/sprites/textBoxes/textBoxes.lua").params
local TextBox = {}
TextBox.__index = TextBox

function TextBox:new(id, x, y, scale, textColor, autoAdvance, max_x)
    local self = setmetatable({}, TextBox)
    self.id = id or "blue"
    self.x = x or 50
    self.y = y or 400
    self.image = ResourceManager.loadTextBox(self.id)
    self.text = ""
    self.visible = false
    self.textCoords = textBoxParams and textBoxParams.textCoords or {45, 100}
    self.scale = scale or 1
    self.textColor = textColor or {1, 1, 1, 1}
    self._fade = 0
    self._fade_target = 1
    self._fade_speed = 1
    self.autoAdvance = autoAdvance or false
    self.max_x = (900 * self.scale)
    return self
end

function TextBox:draw()
    if self.visible and self.image then
        love.graphics.setColor(1, 1, 1, self._fade)
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
        love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], (self.textColor[4] or 1) * self._fade)
        love.graphics.printf(self.text, self.x + self.textCoords[1] * self.scale, self.y + self.textCoords[2] * self.scale, self.max_x)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return TextBox
