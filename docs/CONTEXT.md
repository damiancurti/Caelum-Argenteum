# CONTEXT.md — Resumen ultra-condensado de Caelum Argenteum

Resumen para que una IA o un colaborador entienda el proyecto sin leer los
cinco documentos canónicos completos. Fuente: `docs/PROJECT.md`,
`docs/SYSTEMS.md`, `docs/MAP01.txt`, `docs/ASSETS.md`, `docs/HISTORY.md` y
`README.md`. Versión documental: **4.36.0i**.

## La premisa del juego

Caelum Argenteum es un FPS-RPG de fantasía oscura, independiente, inspirado en
la Argentina del siglo XIX y desarrollado sobre GZDoom 4.14.2/ZScript. La
nación recién formada está dividida por intereses políticos, sociales y
territoriales mientras enfrenta dos invasiones simultáneas.

La primera invasión es exterior: los Caelith, habitantes originarios de la
Luna, descienden sobre la Tierra bajo el mando de la reina Selene. La segunda
es interior: el Tarot, un poder procedente del Infierno, se infiltra en
personas, criaturas, objetos, lugares y conflictos; el Culto del Tarot usa esa
influencia para exacerbar las divisiones y debilitar la resistencia. Ambas
amenazas provienen del plan de un príncipe infernal que, tras fracasar en
conquistar la Tierra por la fuerza, decidió corromper la Luna y quebrar la
Tierra desde dentro.

El protagonista no empieza como héroe ni miembro de una facción: es un errante
que intentaba escapar del conflicto, muere en circunstancias que no recuerda y
despierta en una mansión imposible, sin saber que está en el Limbo. Las
especies principales son alegóricas de la Argentina del siglo XIX: los Hombres
Bestia representan a los pueblos nativos, los Caelith al colonialismo europeo,
los duendes a los gauchos y la cultura rural, y los humanos a la sociedad
urbana porteña.

## Sistemas implementados

- **Combate:** armas físicas cuerpo a cuerpo, armas a distancia e implementos
  mágicos en tres tiers; bloqueo, apuntado/ADS, ataques cargados, barrido de
  armas grandes y Channel de Sellos.
- **Supervivencia:** Hambre, Sed, Sueño, Aire y vida; regeneración,
  necesidades por masa corporal, digestión, descanso y espera.
- **Atributos y habilidades:** doce atributos, habilidades raciales y de clase
  acordadas (solo el Sueño del Arcanista implementado), runas y sellos.
- **Crafting y equipo:** recetas, reparación, desarme, estaciones, armaduras,
  munición (flechas y virotes) y cupos de materiales.
- **Economía y Caja Mágica:** moneda física, transacciones, Caja persistente
  con reducción de peso y contenido restringido.
- **Misiones, reputación y facciones:** base de encargos opcionales, estados,
  condiciones reutilizables de diálogo/acceso/comercio y condiciones de facción.
- **Tarot:** colección persistente y captura de El Loco; pasivas base de los 56
  Arcanos Menores por palo; recompensa de cartas.
- **Mundo y viajes:** Diario de mundo, ubicaciones visitadas, conexiones,
  puertas agrupadas, caravanas, vehículos costeros (carreta y mercante) y
  rutas medidas con provisiones.
- **Tiempo, calendario y clima:** reloj global persistente, calendario civil y
  de campaña (época 1889-11-03 09:00), agenda mensual de eventos, clima
  regional SMN y refugio según posición.
- **Física y peligros:** núcleo Impact Physics, trampilla, foso, rocas, minas
  explosivas, teletransporte, techo aplastador, peso en reposo y palancas.
- **MAP01 (mansión/tutorial):** prólogo, Voz desconocida, Palomo, Argento,
  Caella, Ronnie y Rulo; primera arma, Caja y salida a MAP02.
- **MAP02 (laberinto):** tres sectores, 147 salas, 96 Mandingas, 45 trampas,
  tres llaves, 39 cofres, 195 piezas de equipo, Zupay final, 1 de Copas y
  salida a la costa.
- **Presentación:** primera persona modular, audio de eventos, localización
  español/inglés, fuentes tipográficas propias y transiciones del hub.

## Estado actual

Versión **4.36.0i**. Compilación y pruebas nativas ejecutadas en GZDoom
g4.14.2 sobre Linux con Freedoom de desarrollo. Funcionan la base 4.36
(trampilla, rocas, trampas aprobadas, techo), el laberinto MAP02, la fórmula
de peso en reposo aprobada, las raciones y las mesas de MAP01 a capacidad.

Pendiente:

- Aceptación visual y recorrido en Windows 11.
- Guardado/carga manual interrumpiendo trampas o combates.
- Cerrar 4.36: superficies dañinas, avalanchas, arietes, catapultas y sectores
  móviles, con su integración y validación antes de extraer Impact Physics.

Después de 4.36 sigue 4.37 (Tarot/Trucazo), luego la exportación de prueba de
V4 y, recién después, V5.

## Estructura del repositorio (resumida)

- `src/`: todo lo empaquetado en el PK3 (mapas, ZScript, sprites, modelos,
  fuentes, sonidos, música, gráficos, licencias).
- `docs/`: los cinco documentos canónicos más `CONTEXT.md` y `TASKS.md`.
- `assets/`: fuentes de arte/audio, clima, primera persona, generadores
  opcionales y manifiestos; no se empaqueta en runtime.
- `build/`: PK3 regenerable.
- `archive/`: respaldos de versiones anteriores.
- Raíz: `README.md`, `build_dev.ps1`, `run_dev.bat`, `validate_project.py`.

## Premisas críticas (resumen de las 13)

1. Código e identificadores en inglés; comentarios y documentación en español.
2. Preferir funciones nativas estables de GZDoom 4.14.2 y una sola fuente
   autoritativa de datos.
3. Producto final independiente de los assets de Doom; preservar procedencia.
4. No inventar balance, recetas, historia ni decisiones pendientes.
5. Proteger lo aceptado y validar solo lo afectado.
6. Entregar archivos nuevos/modificados y un TXT de pruebas; sin instaladores.
7. Documentación consolidada y actualizada en cada parche.
8. Cada entrega actualiza versión, estado y resultados en el mismo cambio.
9. Conservar historia y contenido único; no borrar en silencio.
10. Carpetas con responsabilidad clara; empaquetar solo `src`.
11. Todo cambio debe ser trazable a un issue o tarea.
12. Ningún agente borra archivos sin autorización explícita.
13. Los generadores deben ser deterministas (misma entrada, misma salida
    byte a byte).

La lista completa, verbatim, está en `AGENTS.md` y en `docs/PROJECT.md`.
