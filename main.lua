local debug = require("engine.debug")
local resource_manager = require("engine.resource_manager")
local utils = require("engine.utils")
debug.log("INICIO MAIN")
local config = dofile("assets/config.lua")
local lang = dofile("assets/lang.lua")
local language = config.language or "ES"
local firstScene = "assets/scenes/mainScene.lua"
local bg = nil
local debug_flag = config.debug or false
local characters = {}
local dialogBox = nil
local dialogText = ""
local dialogSegments = {}
local dialogIndex = 1
local dialogVisible = false
local dialogCharName = ""
local dialogID = nil
local dialogBoxID = "blue"
local dialogFade = 0
local dialogFadeTarget = 0
local dialogFadeSpeed = 2

local sceneQueue = {}
local sceneIndex = 1
local waiting = false
local sceneCoroutine = nil
local coroutineWaiting = false

-- TextBox support
local TextBox = require("engine.textbox")
local textBoxes = {}
local textBoxFade = 0
local textBoxFadeTarget = 0
local textBoxFadeSpeed = 2
local textBoxVisible = false
local textBoxObj = nil
local textBoxSegments = {}
local textBoxIndex = 1
local textBoxAdvanceRequested = false

local ChoiceButton = require("engine.choicebutton")
local choiceButtons = {}
local choiceButtonGroups = {}
local choiceButtonPressed = {}

function getText(id)
    local missingText = ""
    if debug_flag then
        missingText = "[MISSING ID: " .. tostring(id) .. "]"
    else
        missingText = "[MISSING TEXT]"
    end

    return lang[language][id] or missingText
end

function resource_manager.loadChoiceButton(state)
    local btns = dofile("assets/sprites/choiceButtons/choiceButtons.lua").assets
    local imgPath = btns[state]
    if not imgPath or imgPath == "" then return nil end -- <-- Asegura que no intente cargar un string vacío
    local ok, img = pcall(love.graphics.newImage, "assets/sprites/choiceButtons/" .. imgPath)
    if not ok or not img then return nil end
    return img
end

local function splitSegments(text)
    local segments = {}
    for seg in string.gmatch(text, "(.-)/%*/") do
        table.insert(segments, seg)
    end
    -- Si el texto no termina en /*/, agregar el último segmento
    local last = text:match(".*/%*/(.*)$")
    if last and last ~= "" then table.insert(segments, last) end
    if #segments == 0 then table.insert(segments, text) end
    return segments
end

local function showDialogBox(id, charName, fade, scale, textColor, nameColor, autoAdvance, max_x)
    dialogID = id
    dialogCharName = charName or ""
    dialogSegments = splitSegments(getText(id))
    dialogIndex = 1
    dialogVisible = true
    dialogFade = 0
    dialogFadeTarget = 1
    dialogFadeSpeed = 1 / ((fade or 500) / 1000)
    dialogText = dialogSegments[1] or ""
    if not dialogBox then
        resource_manager.loadAll()
        local DialogBox = require("engine.dialogbox")
        dialogBox = DialogBox:new(dialogBoxID, 50, 400, scale or 0.7, textColor, nameColor, (autoAdvance == true), max_x)
    else
        dialogBox.scale = scale or 1
        dialogBox.textColor = textColor or {1, 1, 1}
        dialogBox.nameColor = nameColor or {1, 1, 1}
        dialogBox.autoAdvance = (autoAdvance == true)
        if max_x then dialogBox.max_x = max_x end
    end
    dialogBox.text = dialogText
    dialogBox.charName = dialogCharName
    dialogBox.visible = true
end

-- Nota: No tengo idea de qué hice aquí, pero funciona, así que no lo toques xd

local function nextDialogSegment()
    if dialogIndex < #dialogSegments then
        dialogIndex = dialogIndex + 1
        dialogText = dialogSegments[dialogIndex]
        dialogBox.text = dialogText
    else
        dialogAdvanceRequested = true
    end
end

local Engine = {}
Engine.__index = Engine

function Engine:loadBackground(id, time)
    resource_manager.loadAll()
    if id == "null" and time == "null" then
        bg = false -- No hay fondo, se limpia
    else
        bg = resource_manager.loadBackground(id, time)
    end
    coroutine.yield()
end

function Engine:loadCharacter(charID, spriteID, expression, x, y, scale)
    resource_manager.loadAll()
    local Character = require("engine.character")
    local char = Character:new(spriteID, x, y, expression, scale or 1)
    characters[charID] = char
    coroutine.yield()
end

function Engine:showCharacter(charID, fade_ms)
    local char = characters[charID]
    if char then
        char.visible = true
        char._fade = 0
        char._fade_target = 1
        char._fade_speed = 1 / ((fade_ms or 500) / 1000)
        while char._fade < 1 do coroutine.yield() end
    end
end

function Engine:hideCharacter(charID, fade_ms)
    local char = characters[charID]
    if char then
        char._fade_target = 0
        char._fade_speed = 1 / ((fade_ms or 500) / 1000)
        while char._fade > 0 do coroutine.yield() end
        char.visible = false
    end
end

-- No mires detrás de tí... De seguro hay un SHOWDIALOG MALDITO TRATANDO DE OBLIGARTE A DEBUGGEAR TRES PVTAS HORAS SEGUIDAS!
function Engine:showDialog(id, charName, fade, scale, textColor, nameColor, autoAdvance, max_x)
    showDialogBox(id, charName, fade, scale, textColor, nameColor, autoAdvance, max_x)
    dialogAdvanceRequested = false
    if dialogBox and dialogBox.autoAdvance then
        -- Avanza automáticamente por cada segmento con un pequeño delay
        for i = 1, #dialogSegments do
            dialogIndex = i
            dialogText = dialogSegments[dialogIndex]
            dialogBox.text = dialogText
            local timer = 0
            while timer < 2 do -- 2 segundos por segmento
                timer = timer + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                coroutine.yield()
            end
        end
        -- No ocultar el dialogBox, solo dejar de bloquear el flujo
    else
        while not (dialogIndex >= #dialogSegments and dialogAdvanceRequested) do coroutine.yield() end
        -- No ocultar el dialogBox, solo desbloquear el flujo
    end
end

function Engine:loadScene(path)
    local sceneFunc = dofile(path)
    local engine = setmetatable({}, Engine)
    sceneCoroutine = coroutine.create(function() sceneFunc(engine) end)
    coroutine.yield()
end

function Engine:fadeIn(ms)
    local done = false
    utils.fadeIn(ms or 500, function() done = true end)
    while not done do coroutine.yield() end
end

function Engine:fadeOut(ms)
    local done = false
    utils.fadeOut(ms or 500, function() done = true end)
    while not done do coroutine.yield() end
end

function Engine:wait(ms)
    local timer = 0
    local duration = (ms or 500) / 1000
    while timer < duration do
        timer = timer + (love.timer.getDelta and love.timer.getDelta() or 0.016)
        coroutine.yield()
    end
end

function Engine:setDialogText(id, charName, autoAdvance)
    dialogID = id
    dialogCharName = charName or ""
    dialogSegments = splitSegments(getText(id))
    dialogIndex = 1
    dialogText = dialogSegments[1] or ""
    if dialogBox then
        dialogBox.text = dialogText
        dialogBox.charName = dialogCharName
        dialogBox.autoAdvance = (autoAdvance == true)
    end
    dialogVisible = true
    dialogFadeTarget = 1
    dialogAdvanceRequested = false
    if dialogBox and dialogBox.autoAdvance then
        for i = 1, #dialogSegments do
            dialogIndex = i
            dialogText = dialogSegments[dialogIndex]
            dialogBox.text = dialogText
            local timer = 0
            while timer < 2 do
                timer = timer + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                coroutine.yield()
            end
        end
    else
        while not (dialogIndex >= #dialogSegments and dialogAdvanceRequested) do coroutine.yield() end
    end
end

function Engine:hideDialog(fade)
    dialogVisible = false
    dialogFadeTarget = 0
    dialogFadeSpeed = 1 / ((fade or 500) / 1000)
    while dialogFade > 0 do coroutine.yield() end
end

function Engine:showText(txtID, fade, scale, textColor, autoAdvance, max_x)
    local textBoxData = dofile("assets/sprites/textBoxes/textBoxes.lua")
    local textBoxID = "blue"
    if not textBoxObj then
        textBoxObj = TextBox:new(textBoxID, 50, 400, scale or 0.7, textColor or {1, 1, 1, 1}, autoAdvance, max_x)
    else
        textBoxObj.scale = scale or 0.7
        textBoxObj.textColor = textColor or {1, 1, 1, 1}
        textBoxObj.autoAdvance = autoAdvance or false
        if max_x then textBoxObj.max_x = max_x end
        if textBoxObj.id ~= textBoxID then
            textBoxObj.id = textBoxID
            textBoxObj.image = require("engine.resource_manager").loadTextBox(textBoxID)
        end
    end
    textBoxSegments = splitSegments(getText(txtID))
    textBoxIndex = 1
    textBoxObj.text = textBoxSegments[1] or ""
    textBoxObj.visible = true
    textBoxObj._fade = 0
    textBoxObj._fade_target = 1
    textBoxObj._fade_speed = 1 / ((fade or 500) / 1000)
    textBoxFade = 0
    textBoxFadeTarget = 1
    textBoxFadeSpeed = 1 / ((fade or 500) / 1000)
    textBoxVisible = true
    textBoxAdvanceRequested = false
    if textBoxObj.autoAdvance then
        for i = 1, #textBoxSegments do
            textBoxIndex = i
            textBoxObj.text = textBoxSegments[textBoxIndex]
            local timer = 0
            while timer < 0.8 do
                timer = timer + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                coroutine.yield()
            end
        end
        textBoxAdvanceRequested = true
    else
        while not textBoxAdvanceRequested do
            coroutine.yield()
        end
    end
end

local function nextTextBoxSegment()
    if textBoxIndex < #textBoxSegments then
        textBoxIndex = textBoxIndex + 1
        textBoxObj.text = textBoxSegments[textBoxIndex]
    else
        textBoxAdvanceRequested = true
    end
end

function Engine:hideText(fade)
    textBoxVisible = false
    textBoxFadeTarget = 0
    textBoxFadeSpeed = 1 / ((fade or 500) / 1000)
    -- El textbox se ocultará visualmente, pero no se bloquea el flujo
end

function Engine:waitForAction()
    waiting = true
    while waiting do coroutine.yield() end
end

function Engine:addChoiceButton(groupID, btnID, enabled, x, y, textID, fade, scale, max_x)
    local text = getText(textID)
    local btn = ChoiceButton:new(groupID, btnID, enabled, x, y, text, fade, scale, max_x)
    if not choiceButtons[groupID] then choiceButtons[groupID] = {} end
    choiceButtons[groupID][btnID] = btn
    btn._fade = 0
    btn._fade_target = 1
    btn._fade_speed = 1 / ((fade or 500) / 1000)
    btn.visible = true
    btn.pressed = false
    return btn
end

function Engine:isChoiceButtonPressed(groupID, btnID)
    return choiceButtonPressed[groupID] and choiceButtonPressed[groupID][btnID] or false
end

-- NO TOQUES ESTO! ENSERIO. ESTUVE HORAS DEBUGGEANDO
function Engine:sync(actions)
    -- Ejecutar todas las acciones en corutinas y esperar a que todas terminen
    local threads = {}
    for i, act in ipairs(actions) do
        threads[i] = coroutine.create(act)
    end
    local alive = #threads
    while alive > 0 do
        alive = 0
        for i, co in ipairs(threads) do
            if coroutine.status(co) ~= "dead" then
                alive = alive + 1
                local ok, err = coroutine.resume(co)
                if not ok then error(err) end
            end
        end
        if alive > 0 then coroutine.yield() end
    end
end

-- Esperar a que se presione un botón de un grupo específico
function Engine:waitForChoice(groupID)
    while true do
        for btnID, btn in pairs(choiceButtons[groupID] or {}) do
            if btn.pressed then
                return btn
            end
        end
        coroutine.yield()
    end
end

function love.load()
    -- Limpiar logs al iniciar
    local f = io.open("debug.log", "w") if f then f:close() end
    local f2 = io.open("debug_char.log", "w") if f2 then f2:close() end
    local sceneFunc = dofile(firstScene)
    local engine = setmetatable({}, Engine)
    sceneCoroutine = coroutine.create(function() sceneFunc(engine) end)
end

function love.update(dt)
    utils.updateFade(dt)
    for _, char in pairs(characters) do
        if char._fade and char._fade_target ~= nil then
            if char._fade < char._fade_target then
                char._fade = math.min(char._fade + (char._fade_speed or 1) * dt, char._fade_target)
            elseif char._fade > char._fade_target then
                char._fade = math.max(char._fade - (char._fade_speed or 1) * dt, char._fade_target)
            end
            if char._fade_target == 0 and char._fade == 0 then
                char.visible = false
            end
        end
    end
    if dialogVisible and dialogFade < dialogFadeTarget then
        dialogFade = math.min(dialogFade + dialogFadeSpeed * dt, dialogFadeTarget)
    elseif not dialogVisible and dialogFade > 0 then
        dialogFade = math.max(dialogFade - dialogFadeSpeed * dt, 0)
    end
    -- Chuck, si ves esto, arregla el maldito lavaplatos :v (Quien mrd es Chuck? XD)
    if textBoxObj and (textBoxFade < textBoxFadeTarget or textBoxFade > textBoxFadeTarget) then
        if textBoxVisible and textBoxFade < textBoxFadeTarget then
            textBoxFade = math.min(textBoxFade + textBoxFadeSpeed * dt, textBoxFadeTarget)
        elseif not textBoxVisible and textBoxFade > 0 then
            textBoxFade = math.max(textBoxFade - textBoxFadeSpeed * dt, 0)
            if textBoxFade == 0 then
                textBoxObj.visible = false
            end
        end
    end
    -- Ejecutar la coroutine de la escena si no está esperando
    if sceneCoroutine and coroutine.status(sceneCoroutine) ~= "dead" then
        local ok, err = xpcall(function() return coroutine.resume(sceneCoroutine) end, function(e) return e end)
        if not ok and err == "__LOAD_SCENE__" then
            -- Reiniciar la escena con la nueva función
            if _G.__nextSceneFunc then
                local engine = setmetatable({}, Engine)
                sceneCoroutine = coroutine.create(function() _G.__nextSceneFunc(engine) end)
                _G.__nextSceneFunc = nil
            end
        elseif not ok and err then
            error(err)
        end
    end
    -- ACTUALIZAR FADE DE LOS CHOICE BUTTONS (SE ME JODIÓ EL BLOQ MAYUS)
    -- Ya lo arreglé :D
    for groupID, group in pairs(choiceButtons) do
        for btnID, btn in pairs(group) do
            if btn._fade and btn._fade_target ~= nil then
                if btn._fade < btn._fade_target then
                    btn._fade = math.min(btn._fade + (btn._fade_speed or 1) * dt, btn._fade_target)
                elseif btn._fade > btn._fade_target then
                    btn._fade = math.max(btn._fade - (btn._fade_speed or 1) * dt, btn._fade_target)
                end
            end
        end
    end
end

-- AHHHH! ODIO LUA!
function love.mousepressed(x, y, button)
    if button == 1 then
        for groupID, group in pairs(choiceButtons) do
            for btnID, btn in pairs(group) do
                if btn.visible and btn.enabled and btn:isInside(x, y) then
                    btn.pressed = true
                    if not choiceButtonPressed[groupID] then choiceButtonPressed[groupID] = {} end
                    choiceButtonPressed[groupID][btnID] = true
                    local debug = require("engine.debug")
                    debug.log("El botón [" .. tostring(btnID) .. "] del grupo [" .. tostring(groupID) .. "] ha sido presionado")
                end
            end
        end
        waiting = false
    end
end

function love.keypressed(key)
    if dialogVisible and key == config.controls.action and (not dialogBox.autoAdvance) then
        if dialogIndex < #dialogSegments then
            nextDialogSegment()
        elseif dialogIndex >= #dialogSegments then
            dialogAdvanceRequested = true
        end
        -- No ocultar el dialogBox automáticamente al terminar los segmentos
    elseif textBoxObj and textBoxObj.visible and key == config.controls.action and (not textBoxObj.autoAdvance) then
        nextTextBoxSegment()
    end
    if _G.__waitForAction and key == config.controls.action then
        waitForActionFlag = true
    end
end

function Engine:hideCButton(groupID, btnID, fade)
    local btn = choiceButtons[groupID] and choiceButtons[groupID][btnID]
    if btn then
        if fade and fade > 0 then
            btn._fade_target = 0
            btn._fade_speed = 1 / ((fade or 500) / 1000)
            -- Esperar a que termine el fade antes de ocultar
            while btn._fade > 0 do coroutine.yield() end
        end
        btn.visible = false
    end
end

-- Preload de expresiones de personajes
local preloadedExpressions = {}

function Engine:preloadExpression(charID, spriteID, expression)
    preloadedExpressions[charID] = preloadedExpressions[charID] or {}
    local img = resource_manager.loadCharacterSprite(spriteID, expression)
    if img then
        preloadedExpressions[charID][expression] = img
    end
end

function Engine:applyExpression(charID, expression)
    local char = characters[charID]
    if char and preloadedExpressions[charID] and preloadedExpressions[charID][expression] then
        char.expression = expression
        char.sprite = preloadedExpressions[charID][expression]
    elseif char then
        -- Si no está pre-cargada, cargarla normal
        char:loadExpression(expression)
    end
end

local function xor_crypt(str, key)
    local res = {}
    for i = 1, #str do
        local c = string.byte(str, i)
        local k = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(res, string.char(bit.bxor(c, k)))
    end
    return table.concat(res)
end

local function tohex(str)
    return (str:gsub('.', function(c)
        return string.format('%02X', string.byte(c))
    end))
end

local function fromhex(hex)
    return (hex:gsub('..', function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

local function get_save_path()
    local sep = package.config:sub(1,1)
    local home = os.getenv('HOME') or os.getenv('USERPROFILE')
    local appdata = os.getenv('APPDATA') or os.getenv('XDG_CONFIG_HOME')
    local folder, file
    if love.system.getOS() == 'Windows' then
        folder = (appdata or (home .. sep .. 'AppData' .. sep .. 'Local')) .. sep .. 'VNEngine'
    else
        folder = (os.getenv('XDG_CONFIG_HOME') or (home .. sep .. '.config')) .. sep .. 'VNEngine'
    end
    file = folder .. sep .. 'game.lua'
    -- Crear carpeta si no existe
    love.filesystem.createDirectory(folder)
    return file
end

-- FLAGS EN MEMORIA Y FLUSH
Engine._flags = nil

local function loadFlagsFromFile()
    local key = 'VNSecretKey'
    local flags = {}

    -- Try to read from LÖVE save directory (cross-platform)
    local ok, data = pcall(love.filesystem.read, "game.lua")
    if ok and data and type(data) == 'string' and #data > 0 then
        local fn, err = load(data)
        if fn then
            local success, chunk = pcall(fn)
            if success and type(chunk) == 'table' then
                for _, pair in ipairs(chunk) do
                    table.insert(flags, {pair[1], pair[2]})
                end
            else
                debug.log("Flags file loaded but did not return a table")
            end
        else
            debug.log("Error compiling flags file: " .. tostring(err))
        end
    else
        -- No file in save dir or read failed; return empty flags
        if not ok then debug.log("love.filesystem.read error reading game.lua: " .. tostring(data)) end
    end

    return flags or {}
end

function Engine:_ensureFlagsLoaded()
    if not self._flags or type(self._flags) ~= 'table' then
        self._flags = loadFlagsFromFile()
        if type(self._flags) ~= 'table' then self._flags = {} end
    end
end

function Engine:saveFlag(name, value)
    self:_ensureFlagsLoaded()
    local key = 'VNSecretKey'
    local enc_name = tohex(xor_crypt(name, key))
    local enc_value = tohex(xor_crypt(value, key))
    local found = false
    for i, pair in ipairs(self._flags) do
        if pair[1] == enc_name then
            pair[2] = enc_value
            found = true
            break
        end
    end
    if not found then
        table.insert(self._flags, {enc_name, enc_value})
    end
end

function Engine:getFlag(name)
    self:_ensureFlagsLoaded()
    local key = 'VNSecretKey'
    local enc_name = tohex(xor_crypt(name, key))
    for _, pair in ipairs(self._flags) do
        if pair[1] == enc_name then
            return xor_crypt(fromhex(pair[2]), key)
        end
    end
    return nil
end

function Engine:flushFlags()
    self:_ensureFlagsLoaded()
    local file = "game.lua"
    local lines = {"return {\n"}
    for _, pair in ipairs(self._flags) do
        table.insert(lines, string.format('    {"%s", "%s"},\n', pair[1], pair[2]))
    end
    table.insert(lines, "}\n")
    local content = table.concat(lines)
    love.filesystem.write(file, content)
end

function Engine:exit()
    love.event.quit()
end

function Engine:setTBText(id, autoAdvance)
    textBoxSegments = splitSegments(getText(id))
    textBoxIndex = 1
    if textBoxObj then
        textBoxObj.text = textBoxSegments[1] or ""
        textBoxObj.autoAdvance = autoAdvance or false
        textBoxObj.visible = true
        textBoxFadeTarget = 1
    end
    textBoxVisible = true
    if textBoxObj and textBoxObj.autoAdvance then
        for i = 1, #textBoxSegments do
            textBoxIndex = i
            textBoxObj.text = textBoxSegments[textBoxIndex]
            local timer = 0
            while timer < 0.8 do
                timer = timer + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                coroutine.yield()
            end
        end
        textBoxAdvanceRequested = true
    else
        textBoxAdvanceRequested = false
        while not textBoxAdvanceRequested do
            coroutine.yield()
        end
    end
end

local musicSource = nil
local soundSources = {}
local currentMusicID = nil

function Engine:playMusic(musicID, loop, volume, fadeIn)
    local path = "assets/music/" .. musicID .. ".ogg"
    if musicSource then
        self:stopMusic(fadeIn or 0)
    end
    local ok, src = pcall(love.audio.newSource, path, "stream")
    if not ok or not src then return end
    musicSource = src
    currentMusicID = musicID
    src:setLooping(loop or true)
    src:setVolume(volume or 1)
    if fadeIn and fadeIn > 0 then
        src:setVolume(0)
        src:play()
        local t = 0
        while t < fadeIn/1000 do
            t = t + (love.timer.getDelta and love.timer.getDelta() or 0.016)
            src:setVolume(math.min((t/(fadeIn/1000)) * (volume or 1), volume or 1))
            coroutine.yield()
        end
        src:setVolume(volume or 1)
    else
        src:play()
    end
end

function Engine:stopMusic(fadeOut)
    if musicSource then
        if fadeOut and fadeOut > 0 then
            local v = musicSource:getVolume()
            local t = 0
            while t < fadeOut/1000 do
                t = t + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                musicSource:setVolume(v * (1 - t/(fadeOut/1000)))
                coroutine.yield()
            end
        end
        musicSource:stop()
        musicSource = nil
        currentMusicID = nil
    end
end

function Engine:playSound(soundID, loop, volume, fadeIn)
    local path = "assets/sounds/" .. soundID .. ".ogg"
    local ok, src = pcall(love.audio.newSource, path, "static")
    if not ok or not src then return end
    src:setLooping(loop or false)
    src:setVolume(volume or 1)
    if fadeIn and fadeIn > 0 then
        src:setVolume(0)
        src:play()
        local t = 0
        while t < fadeIn/1000 do
            t = t + (love.timer.getDelta and love.timer.getDelta() or 0.016)
            src:setVolume(math.min((t/(fadeIn/1000)) * (volume or 1), volume or 1))
            coroutine.yield()
        end
        src:setVolume(volume or 1)
    else
        src:play()
    end
    soundSources[soundID] = src
end

function Engine:stopSound(soundID, fadeOut)
    local src = soundSources[soundID]
    if src then
        if fadeOut and fadeOut > 0 then
            local v = src:getVolume()
            local t = 0
            while t < fadeOut/1000 do
                t = t + (love.timer.getDelta and love.timer.getDelta() or 0.016)
                src:setVolume(v * (1 - t/(fadeOut/1000)))
                coroutine.yield()
            end
        end
        src:stop()
        soundSources[soundID] = nil
    end
end

function Engine:updateMusicVolume(volume)
    if musicSource then
        musicSource:setVolume(volume or 1)
    end
end

function Engine:updateSoundVolume(soundID, volume)
    local src = soundSources[soundID]
    if src then
        src:setVolume(volume or 1)
    end
end

local sprites = {}

function Engine:showSprite(spriteObjID, spriteID, x, y, fadeIn, scale)
    resource_manager.loadAll()
    local img = resource_manager.loadCharacterSprite(spriteID, "normal")
    if not img then return end
    sprites[spriteObjID] = {
        image = img,
        x = x or 0,
        y = y or 0,
        scale = scale or 1,
        _fade = 0,
        _fade_target = 1,
        _fade_speed = 1 / ((fadeIn or 500) / 1000),
        visible = true
    }
    -- Fade in
    while sprites[spriteObjID]._fade < 1 do
        sprites[spriteObjID]._fade = math.min(sprites[spriteObjID]._fade + sprites[spriteObjID]._fade_speed * (love.timer.getDelta and love.timer.getDelta() or 0.016), 1)
        coroutine.yield()
    end
end

function Engine:hideSprite(spriteObjID, fadeOut)
    local spr = sprites[spriteObjID]
    if spr then
        spr._fade_target = 0
        spr._fade_speed = 1 / ((fadeOut or 500) / 1000)
        while spr._fade > 0 do
            spr._fade = math.max(spr._fade - spr._fade_speed * (love.timer.getDelta and love.timer.getDelta() or 0.016), 0)
            coroutine.yield()
        end
        spr.visible = false
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    if bg then
        love.graphics.print(" Background listo", 10, 10)
        love.graphics.draw(bg, 0, 0, 0, love.graphics.getWidth()/bg:getWidth(), love.graphics.getHeight()/bg:getHeight())
    else
        if debug_flag then
            love.graphics.print("[DEBUG] Sin background", 10, 10)
        end
    end
    local y = 30
    for id, char in pairs(characters) do
        if char.visible then
            if debug_flag then 
                love.graphics.print("[DEBUG] Personaje " .. tostring(id) .. " visible, fade: " .. tostring(char._fade or 1), 10, y)
                love.graphics.print("[DEBUG] char.sprite: " .. tostring(char.sprite), 300, y)
                love.graphics.print("[DEBUG] char._fade: " .. tostring(char._fade), 600, y)
            end
            char:draw(char._fade)
            love.graphics.setColor(1, 1, 1, 1)
        else
            if debug_flag then
                love.graphics.print("[DEBUG] Personaje " .. tostring(id) .. " NO visible", 10, y)
                love.graphics.print("[DEBUG] char.sprite: " .. tostring(char.sprite), 300, y)
                love.graphics.print("[DEBUG] char._fade: " .. tostring(char._fade), 600, y)
            end
        end
        y = y + 20
    end
    -- Dibujar sprites genéricos
    for id, spr in pairs(sprites) do
        if spr.visible and spr._fade > 0 and spr.image then
            love.graphics.setColor(1, 1, 1, spr._fade)
            love.graphics.draw(spr.image, spr.x, spr.y, 0, spr.scale or 1, spr.scale or 1)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    if dialogBox and dialogFade > 0 then
        if debug_flag then
            love.graphics.print("[DEBUG] DialogBox visible, fade: " .. tostring(dialogFade), 10, y)
        end
        love.graphics.setColor(1, 1, 1, dialogFade)
        dialogBox:draw()
        love.graphics.setColor(1, 1, 1, 1)
    else
        if debug_flag then
            love.graphics.print("[DEBUG] Sin dialogBox visible", 10, y)
        end
    end
    if textBoxObj and textBoxObj.visible and textBoxFade > 0 then
        textBoxObj._fade = textBoxFade
        love.graphics.setColor(1, 1, 1, textBoxFade)
        textBoxObj:draw()
        love.graphics.setColor(1, 1, 1, 1)
    end
    local mx, my = love.mouse.getPosition()
    for groupID, group in pairs(choiceButtons) do
        for btnID, btn in pairs(group) do
            local isHovered = btn:isInside(mx, my)
            btn:draw(isHovered)
        end
    end
    utils.drawFade()
end