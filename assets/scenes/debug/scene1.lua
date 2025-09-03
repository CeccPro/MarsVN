return function(engine)
    engine:fadeOut(0)
    engine:loadBackground("classroom1", "day1")
    engine:loadCharacter("keiko", "keiko_schoolsummer", "happy", 250, -125, 1)
    engine:fadeIn(500)
    engine:showCharacter("keiko", 1000)
    engine:showDialog("diag_keiko_test1", "Keiko", 500, 0.7, {0, 0, 0, 1}, {0, 0, 0, 1})
    engine:wait(500) -- Espera medio segundo tras el diálogo
    engine:hideDialog(500)
    engine:hideCharacter("keiko", 1000)
    engine:wait(500) -- Espera medio segundo antes de cambiar de escena
    engine:hideDialog(500)
    engine:wait(500)
    engine:fadeOut(500)
    engine:loadScene("assets/scenes/debug/scene2.lua")
end
