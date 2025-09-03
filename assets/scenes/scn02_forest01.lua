-- assets/scenes/scn02_forest01.lua
-- Esta escena se carga después de que el jugador acepta la invitación de Keiko en la escena principal.

return function (engine)
    engine:fadeOut(0) -- Preparar fade in para transición suave al siguiente fondo

    -- Cargar assets
    engine:loadBackground("null", "null")
    engine:loadCharacter("keiko", "keiko_schoolsummer", "happy", 250, -125, 1)

    -- Mostrar primer textbox
    engine:fadeIn(0) -- No hay fondo, así que no se nota el fade in
    engine:showText("txt_scn2_01", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:fadeOut(500)
    engine:loadBackground("hallway", "day1")
    engine:fadeIn(500)
    engine:showText("txt_scn2_02", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:showCharacter("keiko", 500)
    engine:showDialog("diag_keiko_scn2_01", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1}, false)
    engine:hideDialog(500)
    engine:wait(100)
    engine:sync({
        function () engine:showText("txt_scn2_quest1", 500, 0.7, {0, 0, 0, 1}, true) end,
        function () engine:addChoiceButton("quest2", "btn1_quest2", true, 50, 250, "txt_scn2_quest1_opt1", 500, 0.4) end,
        function () engine:addChoiceButton("quest2", "btn2_quest2", true, 50, 300, "txt_scn2_quest1_opt2", 500, 0.4) end,
        function () engine:addChoiceButton("quest2", "btn3_quest2", true, 50, 350, "txt_scn2_quest1_opt3", 500, 0.4) end
    })

    -- Esperar la elección del jugador
    local pressedBtn = engine:waitForChoice("quest2")
    engine:sync({
        function () engine:hideCButton("quest2", "btn1_quest2", 500) end,
        function () engine:hideCButton("quest2", "btn2_quest2", 500) end,
        function () engine:hideCButton("quest2", "btn3_quest2", 500) end,
        function () engine:hideText(500) end,
        function () engine:preloadExpression("keiko", "pout") end,
        function () engine:wait(500) end
    })

    if pressedBtn and pressedBtn.btnID == "btn2_quest2" then
        -- El jugador eligió rechazar la invitación de Keiko
        engine:fadeOut(500)
        engine:hideCharacter("keiko", 500)
        engine:loadBackground("null", "null")
        engine:fadeIn(500)
        engine:showText("txt_scn2_04", 500, 0.7, {0, 0, 0, 1})
        engine:hideText(500)
        engine:wait(700)
        engine:exit()
    elseif pressedBtn and pressedBtn.btnID == "btn3_quest2" then
        -- El jugador eligió proponer ir a otro lugar
        engine:showText("txt_scn2_05", 500, 0.7, {0, 0, 0, 1})
        engine:hideText(500)
        engine:applyExpression("keiko", "pout", 500)
        engine:wait(500)
        engine:showDialog("diag_keiko_scn2_03", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
        engine:hideDialog(500)
        engine:wait(500)
        engine:fadeOut(500)
        engine:hideCharacter("keiko", 500)
        -- Aquí va otra escena aún no lista. Por ahora, solo salimos
        -- PD: Esto lo escribí hace medio mes, así que no recuerdo qué escena era xd
        -- Espero arreglarlo pronto, o al menos antes de que salga la demo XD. Si no alta
        -- mala reseña que me van a tirar en Steam XD
        engine:exit()
    end

    -- El jugador eligió aceptar la invitación de Keiko
    engine:showText("txt_scn2_03", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:wait(500)
    engine:showDialog("diag_keiko_scn2_02", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:hideDialog(500)
    engine:wait(500)
    engine:fadeOut(500)
    engine:hideCharacter("keiko", 0)
    engine:loadBackground("forest2", "day1")
    engine:fadeIn(500)
end