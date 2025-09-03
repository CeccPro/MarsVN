return function(engine)
    engine:fadeOut(0)
    engine:loadBackground("classroom2", "evening")
    engine:loadCharacter("keiko", "keiko_schoolwinter", "happy", 250, -125, 1)
    engine:fadeIn(500)
    engine:showCharacter("keiko", 1000)
    engine:sync({
        function () engine:showDialog("diag_keiko_buttons_test", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1}, true) end,
        function () engine:addChoiceButton("grupo1", "btn_test_01", true, 50, 300, "btn_test_txt01", 500, 0.4) end,
        function () engine:addChoiceButton("grupo1", "btn_test_02", true, 50, 350, "btn_test_txt02", 500, 0.4) end
    })
    local pressedBtn = engine:waitForChoice("grupo1")
    engine:sync({
        function () engine:hideCButton("grupo1", "btn_test_01", 500) end,
        function () engine:hideCButton("grupo1", "btn_test_02", 500) end
    })
    if pressedBtn and pressedBtn.btnID == "btn_test_01" then
        engine:setDialogText("diag_keiko_buttons_pressed_01", "Keiko")
    elseif pressedBtn and pressedBtn.btnID == "btn_test_02" then
        engine:setDialogText("diag_keiko_buttons_pressed_02", "Keiko")
    end
    engine:wait(500)
    engine:hideCharacter("keiko", 1000)
    engine:hideDialog(500)
    engine:fadeOut(500)
    engine:saveFlag("endedDebug", "1")
    engine:flushFlags()
    engine:wait(700)
    engine:exit()
end