local debug = require("engine.debug")

local resource_manager = {}

local function loadTable(path)
    local ok, data = pcall(dofile, path)
    if ok and type(data) == "table" then
        return data
    else
        debug.log("Error al cargar tabla: " .. tostring(path))
        return nil
    end
end

local characters = {}
local backgrounds = {}
local sprites = {}
local dialogboxes = {}

function resource_manager.loadAll()
    characters = loadTable("assets/characters/characters.lua") or {}
    backgrounds = loadTable("assets/backgrounds/backgrounds.lua") or {}
    sprites = loadTable("assets/sprites/sprites.lua") or {}
    dialogboxes = loadTable("assets/sprites/dialogBoxes/dialogBoxes.lua") or {}
end

function resource_manager.getCharacterData(id)
    if not characters.assets or not characters.assets[id] then
        debug.log("Personaje no encontrado: " .. tostring(id))
        return nil
    end
    local path = "assets/characters/" .. characters.assets[id]
    return loadTable(path)
end

function resource_manager.loadCharacterSprite(id, expression)
    local data = resource_manager.getCharacterData(id)
    if not data or not data.assets or not data.assets[expression] then
        debug.log("Sprite de expresión no encontrada: " .. tostring(id) .. " - " .. tostring(expression))
        return nil
    end
    local imgPath = "assets/characters/" .. id .. "/" .. data.assets[expression]
    debug.log("Cargando sprite: " .. imgPath)
    local ok, img = pcall(love.graphics.newImage, imgPath)
    if not ok or not img then
        debug.log("Error al cargar imagen: " .. imgPath)
        return nil
    end
    return img
end

function resource_manager.loadBackground(id, time)
    if not backgrounds.bg or not backgrounds.bg[id] then
        debug.log("Background no encontrado: " .. tostring(id))
        return nil
    end
    local path = "assets/backgrounds/" .. backgrounds.bg[id]
    debug.log("Intentando cargar tabla de fondo: " .. path)
    local data = loadTable(path)
    if not data or not data.assets or not data.assets[time] then
        debug.log("Tiempo de background no encontrado: " .. tostring(id) .. " - " .. tostring(time))
        return nil
    end
    local imgPath = "assets/backgrounds/" .. id .. "/" .. data.assets[time]
    debug.log("Intentando cargar imagen de fondo: " .. imgPath)
    local ok, img = pcall(love.graphics.newImage, imgPath)
    if not ok or not img then
        debug.log("Error al cargar imagen de fondo: " .. imgPath)
        return nil
    end
    debug.log("Imagen de fondo cargada correctamente: " .. imgPath)
    return img
end

function resource_manager.loadDialogBox(id)
    if not dialogboxes.assets or not dialogboxes.assets[id] then
        debug.log("DialogBox no encontrado: " .. tostring(id))
        return nil
    end
    local imgPath = "assets/sprites/dialogBoxes/" .. dialogboxes.assets[id]
    debug.log("Cargando dialogBox: " .. imgPath)
    local ok, img = pcall(love.graphics.newImage, imgPath)
    if not ok or not img then
        debug.log("Error al cargar imagen de dialogBox: " .. imgPath)
        return nil
    end
    return img
end

function resource_manager.loadTextBox(id)
    local textBoxes = loadTable("assets/sprites/textBoxes/textBoxes.lua")
    if not textBoxes.assets or not textBoxes.assets[id] then
        debug.log("TextBox no encontrado: " .. tostring(id))
        return nil
    end
    local imgPath = "assets/sprites/textBoxes/" .. textBoxes.assets[id]
    debug.log("Cargando textBox: " .. imgPath)
    local ok, img = pcall(love.graphics.newImage, imgPath)
    if not ok or not img then
        debug.log("Error al cargar imagen de textBox: " .. imgPath)
        return nil
    end
    return img
end

return resource_manager