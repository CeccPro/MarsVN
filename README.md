# VN-Engine 1.0.0

Motor de Visual Novel para LÖVE2D

---

## Descripción
Este proyecto es un motor modular para crear Visual Novels en LÖVE2D (Love2D), con soporte para:
- Diálogos segmentados y control de flujo
- Personajes con expresiones y fades
- Fondos dinámicos y fondos especiales (negro, etc.)
- Botones de elección y sincronización de acciones
- TextBox y DialogBox independientes
- Internacionalización modular (multi-idioma)
- Guardado seguro de flags (encriptado)
- Modularidad para assets, escenas y recursos

---

## Estructura de Carpetas

- `main.lua` — Entrada principal y lógica del motor
- `engine/` — Módulos internos (personajes, diálogos, utilidades, recursos...)
- `assets/` — Recursos del juego
    - `backgrounds/` — Fondos y sus definiciones
    - `characters/` — Personajes y expresiones
    - `langs/` — Archivos de idioma (ES.lua, EN.lua, ...)
    - `music/` — Música de fondo
    - `scenes/` — Escenas del juego (scripts Lua)
    - `sprites/` — Sprites de UI (botones, cajas de texto, etc.)
    - `sounds/` — Efectos de sonido
    - `config.lua` — Configuración global (idioma, controles, debug)
    - `lang.lua` — Carga y gestión de idiomas

---

## Uso de Segmentos de Diálogo

Para dividir un diálogo en varios segmentos (que el usuario debe avanzar), usa el delimitador especial `/*/` en los textos de idioma:

```lua
diag_ejemplo = "Primer segmento/*/Segundo segmento con salto de línea:\n¡Hola!/*/Tercer segmento."
```

- Los saltos de línea normales (`\n`) se mantienen dentro de cada segmento.
- Solo `/*/` separa los bloques que requieren avance manual.

---

## Ejemplo de Escena

```lua
return function(engine)
    engine:showDialog("diag_ejemplo", "Keiko", 500, 0.7, {0,0,0,1}, {0,0,0,1})
    engine:hideDialog(500)
end
```

---

## Guardado Seguro de Flags

- Usa `Engine:saveFlag(name, value)` para guardar un flag (encriptado y hexadecimal)
- Usa `Engine:getFlag(name)` para leer un flag
- Llama a `Engine:flushFlags()` para guardar en disco (no se escribe automáticamente)

---

## Internacionalización

- Los idiomas se cargan automáticamente desde `assets/langs/`.
- El idioma activo se define en `assets/config.lua` (`language = "ES"`, por ejemplo).
- Para agregar un idioma, crea un archivo Lua en `assets/langs/` siguiendo el formato de los existentes.

---

## Personajes y Expresiones

- Los personajes se definen en `assets/characters/characters.lua` y subcarpetas.
- Usa `engine:preloadExpression(charID, spriteID, expression)` para precargar una expresión.
- Usa `engine:applyExpression(charID, expression)` para cambiar instantáneamente la expresión de un personaje.

---

## Fondos Especiales

- Llama a `engine:loadBackground("null", "null")` para quitar el fondo y dejar el fondo negro por defecto.

---

## Control de Flujo y Sincronización

- Usa `engine:sync({func1, func2, ...})` para ejecutar acciones en paralelo y esperar a que todas terminen (útil para fades, botones, etc.)
- El flujo de diálogos y textbox se bloquea hasta que el usuario avance todos los segmentos y presione una vez más.

---

## Controles por Defecto

- Avanzar texto: `space` (configurable en `assets/config.lua`)
- Otros controles pueden definirse en el mismo archivo.

---

## Ejemplo de Texto de Idioma

```lua
return {
    diag_ejemplo = "Hola, esto es un segmento/*/Y esto es otro segmento con salto de línea:\n¡Hola mundo!/*/Fin.",
}
```

---

## Créditos y Licencia

- Motor creado por CeccPro
- Estructura y código modular, fácil de extender.
- Licencia: MIT (puedes modificar y usar libremente, da crédito si lo distribuyes)
