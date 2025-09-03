-- engine/utils.lua
-- Utilidades para transiciones de fade (blackout) en Love2D

local utils = {}

local fade = {
    alpha = 0,           -- Opacidad actual (0 = transparente, 1 = negro total)
    duration = 0,        -- Duración total del fade (en segundos)
    timer = 0,           -- Tiempo transcurrido
    direction = 0,       -- 1 = fadeOut, -1 = fadeIn, 0 = sin fade
    callback = nil       -- Función a llamar al terminar
}

function utils.fadeOut(ms, callback)
    fade.duration = (ms or 500) / 1000
    fade.timer = 0
    fade.direction = 1
    fade.callback = callback
end

function utils.fadeIn(ms, callback)
    fade.duration = (ms or 500) / 1000
    fade.timer = 0
    fade.direction = -1
    fade.callback = callback
end

function utils.updateFade(dt)
    if fade.direction ~= 0 then
        fade.timer = fade.timer + dt
        local t = math.min(fade.timer / fade.duration, 1)
        if fade.direction == 1 then
            fade.alpha = t
        elseif fade.direction == -1 then
            fade.alpha = 1 - t
        end
        if t >= 1 then
            fade.direction = 0
            if fade.callback then fade.callback() end
        end
    end
end

function utils.drawFade()
    if fade.alpha > 0 then
        love.graphics.setColor(0, 0, 0, fade.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function utils.isFading()
    return fade.direction ~= 0 or fade.alpha > 0
end

return utils
