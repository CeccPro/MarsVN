return function(engine)
    engine:loadBackground("classroom1", "evening")
    engine:loadCharacter("keiko", "keiko_schoolsummer", "blush", 250, -125, 1)
    engine:fadeIn(500)
    engine:showCharacter("keiko", 1000)
    engine:showDialog("diag_keiko_test2", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:hideDialog(500)
    engine:wait(500) -- Espera medio segundo tras el diálogo
    engine:hideCharacter("keiko", 1000)
    engine:showText("txt_test_textbox", 500, 0.7, {0, 0, 0, 1})
    engine:hideText(500)
    engine:fadeOut(500)
    engine:loadScene("assets/scenes/debug/scene3.lua")
end
