local ResourceManager = require("engine.resource_manager")
local choiceButtonParams = dofile("assets/sprites/choiceButtons/choiceButtons.lua").params
local ChoiceButton = {}
ChoiceButton.__index = ChoiceButton

function ChoiceButton:new(groupID, btnID, enabled, x, y, text, fade, scale, max_x)
    local self = setmetatable({}, ChoiceButton)
    self.groupID = groupID
    self.btnID = btnID
    self.enabled = enabled
    self.x = x
    self.y = y
    self.text = text or ""
    self.state = enabled and "idle" or "disabled"
    self.visible = true
    self.alpha = 0
    self.fade = fade or 500
    self._fade = 0
    self._fade_target = 1
    self._fade_speed = 1 / ((fade or 500) / 1000)
    self.scale = scale or .3
    self.width = 300 * self.scale
    self.height = 60 * self.scale
    self.textCoords = choiceButtonParams and choiceButtonParams.textCoords or {25, 50}
    self.max_x = ((500) * self.scale)
    self.images = {
        idle = ResourceManager.loadChoiceButton and ResourceManager.loadChoiceButton("idle") or nil,
        hover = ResourceManager.loadChoiceButton and ResourceManager.loadChoiceButton("hover") or nil,
        disabled = ResourceManager.loadChoiceButton and ResourceManager.loadChoiceButton("disabled") or nil
    }
    return self
end

function ChoiceButton:draw(isHovered)
    if not self.visible then return end
    local img = self.images[self.state]
    if isHovered and self.enabled then
        img = self.images["hover"]
    end
    if img then
        love.graphics.setColor(1, 1, 1, self._fade)
        love.graphics.draw(img, self.x, self.y, 0, self.scale, self.scale)
    end
    -- Ajustar tamaño de fuente según escala
    local oldFont = love.graphics.getFont()
    local baseFontSize = oldFont and oldFont:getHeight() or 16
    local scaledFontSize = math.floor(baseFontSize * self.scale * 2.2) -- 2.2 para compensar el .4
    if scaledFontSize < 8 then scaledFontSize = 8 end
    local font = love.graphics.newFont(scaledFontSize)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, self._fade)
    love.graphics.printf(self.text, self.x + self.textCoords[1] * self.scale, self.y + self.textCoords[2] * self.scale, self.max_x, "left")
    love.graphics.setFont(oldFont)
    love.graphics.setColor(1, 1, 1, 1)
end

function ChoiceButton:isInside(mx, my)
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

return ChoiceButton
