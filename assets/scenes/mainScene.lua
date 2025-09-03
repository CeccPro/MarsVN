-- assets/scenes/mainScene.lua
-- Esta escena es la primera escena que se carga.
-- Aquí puedes cargar un menú de inicio, una escena o lo que sea. Si haces un mod, aquí es donde debes empezar.
-- (Aquí puedes meter la lógica para cargar el menú principal, o directamente cargar la escena correspondiente
-- al archivo de guardado)

return function (engine)
    -- Fade out para preparar la escena
    engine:fadeOut(0)
    
    -- Cargar directamente nuestra escena de graduación
    engine:loadScene("assets/scenes/scn01_classroom01.lua")
end