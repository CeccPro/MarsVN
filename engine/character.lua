local ResourceManager = require("engine.resource_manager")
local Character = {}
Character.__index = Character

local function write_debug_file(msg)
    local f = io.open("debug_char.log", "a")
    if f then
        f:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
        f:close()
    end
end

function Character:new(id, x, y, expression, scale)
    local data = ResourceManager.getCharacterData(id)
    local self = setmetatable({}, Character)
    self.id = id
    self.x = x
    self.y = y
    self.expression = expression
    self.sprite = ResourceManager.loadCharacterSprite(id, expression)
    self.visible = false
    self.scale = scale or 1
    -- DEBUG extra: log para saber si el sprite existe
    if not self.sprite then
        write_debug_file("[Character] Sprite no cargado para '" .. tostring(id) .. "' expresión '" .. tostring(expression) .. "'")
    else
        write_debug_file("[Character] Sprite cargado OK para '" .. tostring(id) .. "' expresión '" .. tostring(expression) .. "'")
    end
    return self
end

function Character:loadExpression(expression)
    self.expression = expression
    self.sprite = ResourceManager.loadCharacterSprite(self.id, expression)
end

function Character:draw(alpha)
    local function write_debug_file(msg)
        local f = io.open("debug_char.log", "a")
        if f then
            f:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
            f:close()
        end
    end
    write_debug_file("[Character:draw] visible=" .. tostring(self.visible) .. ", sprite=" .. tostring(self.sprite) .. ", alpha=" .. tostring(alpha) .. ", id=" .. tostring(self.id))
    if self.visible and self.sprite then
        love.graphics.setColor(1, 1, 1, alpha or 1)
        love.graphics.draw(self.sprite, self.x, self.y, 0, self.scale, self.scale)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Character