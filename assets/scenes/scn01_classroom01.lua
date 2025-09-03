-- assets/scenes/scn01_classroom01.lua
-- Esta escena es la primera que se muestra al iniciar el juego.

return function (engine)
    -- fade out para evitar mostrar un corte brusco
    engine:fadeOut(0)

    -- Comentar esto después:
    -- engine:loadScene("assets/scenes/forestScene.lua")

    -- Cargar los assets
    engine:loadBackground("classroom1", "day1")
    engine:loadCharacter("keiko", "keiko_schoolsummer", "sad", 250, -125, 1)

    -- Mostrar el fondo
    engine:fadeIn(500)

    -- Mostrar el primer textbox
    engine:showText("txt_scn1_01", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)

    -- Mostrar la primera decisión
    engine:sync({
        function () engine:showText("txt_scn1_quest1", 500, 0.7, {0, 0, 0, 1}, true) end, 
        function () engine:addChoiceButton("quest1", "btn1_quest1", true, 50, 300, "txt_scn1_quest1_opt1", 500, 0.4) end,
        function () engine:addChoiceButton("quest1", "btn2_quest1", true, 50, 350, "txt_scn1_quest1_opt2", 500, 0.4) end
    })

    -- Esperar la elección del jugador
    local pressedBtn = engine:waitForChoice("quest1")
    engine:sync({
        function () engine:hideCButton("quest1", "btn1_quest1", 500) end,
        function () engine:hideCButton("quest1", "btn2_quest1", 500) end,
        function () engine:hideText(500) end,
        function () engine:wait(500) end
    })

    if pressedBtn and pressedBtn.btnID == "btn2_quest1" then
        -- El jugador eligió salir del aula. Entonces mostrar un fondo negro
        engine:fadeOut(500)
        engine:loadBackground("null", "null")
        engine:fadeIn(500)
        -- Mostrar textbox con dialogo lo suficientemente largo como para que el jugador se sienta mal por dejar sola a Keiko
        -- ¿Porqué? Porque es una buena chica y no merece ser ignorada :v. Ando dolido lpm xd. However, se supone que con este dialogo
        -- se busca generar empatía en el jugador para que no la ignore.
        engine:showText("txt_scn1_03", 500, 0.7, {0, 0, 0, 1})
        engine:hideText(500)
        engine:wait(700)
        engine:exit()
    end

    -- Si el jugador eligió acercarse a la chica
    engine:showText("txt_scn1_02", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:showCharacter("keiko", 500)
    engine:showDialog("diag_keiko_scn1_01", "[???]", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:hideDialog(500)
    engine:wait(100)
    engine:fadeOut(500)
    engine:loadBackground("null", "null")
    engine:hideCharacter("keiko", 500)
    engine:fadeIn(500)

    -- Mostrar texto para pasar a la siguiente parte de la escena
    engine:showText("txt_scn1_04", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:wait(500)
    engine:fadeOut(0) -- Preparar fade in para transición suave al siguiente fondo
    engine:loadCharacter("keiko", "keiko_schoolsummer", "happy", 250, -125, 1)
    engine:preloadExpression("keiko", "blush")
    engine:loadBackground("classroom1", "evening")
    engine:fadeIn(500) -- Mostrar fondo
    engine:wait(500)

    -- Mostrar diálogo de Keiko
    engine:showCharacter("keiko", 500)
    engine:showDialog("diag_keiko_scn1_02", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:applyExpression("keiko", "blush") -- Aplicar expresión de sonrojo
    engine:setDialogText("diag_keiko_scn1_03", "Keiko", false)
    engine:hideDialog(500)
    engine:sync({
        function () engine:showText("txt_scn1_quest2", 500, 0.7, {0, 0, 0, 1}, true) end,
        function () engine:addChoiceButton("quest2", "btn1_quest2", true, 50, 300, "txt_scn1_quest2_opt1", 500, 0.4) end,
        function () engine:addChoiceButton("quest2", "btn2_quest2", true, 50, 350, "txt_scn1_quest2_opt2", 500, 0.4) end
    })
    -- Esperar la elección del jugador
    pressedBtn = engine:waitForChoice("quest2")
    engine:sync({
        function () engine:hideCButton("quest2", "btn1_quest2", 500) end,
        function () engine:hideCButton("quest2", "btn2_quest2", 500) end,
        function () engine:hideText(500) end,
        function () engine:wait(500) end
    })

    if pressedBtn and pressedBtn.btnID == "btn2_quest2" then
        -- El jugador eligió rechazar la invitación de Keiko
        engine:fadeOut(500)
        engine:hideCharacter("keiko", 500)
        engine:loadBackground("null", "null")
        engine:fadeIn(0)
        engine:showText("txt_scn1_06", 500, 0.7, {0, 0, 0, 1})
        engine:hideText(500)
        engine:wait(700)
        engine:exit()
    end

    -- Si el jugador aceptó la invitación de Keiko
    engine:showText("txt_scn1_05", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:wait(500)
    engine:showDialog("diag_keiko_scn1_04", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:hideDialog(500)
    engine:wait(500)
    engine:fadeOut(500)
    engine:hideCharacter("keiko", 500)
    engine:loadScene("assets/scenes/forestScene.lua")
end