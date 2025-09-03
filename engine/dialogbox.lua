local ResourceManager = require("engine.resource_manager")
local dialogBoxParams = dofile("assets/sprites/dialogBoxes/dialogBoxes.lua").params
local DialogBox = {}
DialogBox.__index = DialogBox

function DialogBox:new(id, x, y, scale, textColor, nameColor, autoAdvance, max_x)
    local self = setmetatable({}, DialogBox)
    self.id = id
    self.x = x
    self.y = y
    self.image = ResourceManager.loadDialogBox(id)
    self.text = ""
    self.charName = ""
    self.visible = false
    self.nameCoords = dialogBoxParams and dialogBoxParams.nameCoords or {20, 10}
    self.textCoords = dialogBoxParams and dialogBoxParams.textCoords or {20, 40}
    self.scale = scale or 1
    self.textColor = textColor or {1, 1, 1, 1}
    self.nameColor = nameColor or {1, 1, 1, 1}
    self.autoAdvance = autoAdvance or false
    -- Esta madre de abajo se rompía. Mejor lo dejo fijo, valiendo madres si te pasan el argumento.
    -- De todas formas, ya lo probé y ajusté manualmente. Lo mismo para otros archivos con max_x
    self.max_x = (900 * self.scale) -- default ancho texto
    return self
end

function DialogBox:draw()
    if self.visible and self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
        love.graphics.setColor(self.nameColor[1], self.nameColor[2], self.nameColor[3], self.nameColor[4])
        love.graphics.print(self.charName, self.x + self.nameCoords[1] * self.scale, self.y + self.nameCoords[2] * self.scale)
        love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4])
        love.graphics.printf(self.text, self.x + self.textCoords[1] * self.scale, self.y + self.textCoords[2] * self.scale, self.max_x)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return DialogBox