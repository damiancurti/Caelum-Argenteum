# AGENTS.md — Caelum Argenteum

Manual de arranque para agentes de IA y colaboradores humanos. Este archivo
describe **cómo trabajar** en el proyecto, no qué balance o diseño contiene.
Los valores de balance, las recetas y las decisiones de diseño viven en los
documentos canónicos de `docs/` y en las decisiones del autor.

## Qué es este proyecto

- **Caelum Argenteum** es un FPS-RPG de fantasía oscura independiente,
  inspirado en la Argentina del siglo XIX, desarrollado sobre GZDoom/ZScript.
- **Autor y diseñador:** Damián Curti.
- **Motor objetivo:** GZDoom 4.14.2 (Windows 11).
- **Versión documental actual:** 4.36.0i.
- **Estado:** el producto final debe ser independiente de los assets de Doom.

## Estructura del repositorio

| Ruta | Contenido |
| --- | --- |
| `src/` | Todo lo que se empaqueta en el PK3: mapas (`maps/`), código ZScript (`caelum/`, `impactphysics/`, `crafting/`), sprites, modelos, fuentes, sonidos, música, gráficos y avisos de licencia. |
| `docs/` | Documentación canónica: `PROJECT.md`, `SYSTEMS.md`, `MAP01.txt`, `ASSETS.md`, `HISTORY.md` y los archivos de agente (`CONTEXT.md`, `TASKS.md`). |
| `assets/` | Fuentes de arte y audio, datos climáticos, vistas de primera persona, generadores opcionales (`generators/`), manifiestos y registros de validación. No se empaqueta en runtime. |
| `build/` | PK3 regenerable (`caelum_argenteum_dev.pk3`), reconstruido con `build_dev.ps1`. |
| `archive/` | Respaldos conocidos de versiones anteriores, con utilidad de recuperación. |
| Raíz | `README.md`, `build_dev.ps1`, `run_dev.bat`, `validate_project.py`. |

Solo `src/` entra en `build/caelum_argenteum_dev.pk3`. `assets/generators/`
son utilidades de edición opcionales; sus resultados ya están listos en `src/`.

## Qué documento leer según la tarea

| Tarea | Documento(s) de referencia |
| --- | --- |
| Entender el proyecto, premisas, roadmap, estado y validación actual | `docs/PROJECT.md` |
| Reglas de juego: controles, combate, crafting, economía, Caja, supervivencia, diálogos | `docs/SYSTEMS.md` |
| Historia, canon, especificación de MAP01 y límites de implementación | `docs/MAP01.txt` |
| Audio, arte, primera persona, atribuciones y generadores | `docs/ASSETS.md` |
| Historial de decisiones y documentos anteriores | `docs/HISTORY.md` |
| Instalación, build y estado resumido | `README.md` |
| Resumen rápido antes de leer todo lo anterior | `docs/CONTEXT.md` |
| Lista de tareas activas y criterios de aceptación | `docs/TASKS.md` |

## Convenciones

- Código, identificadores y el README general, **en inglés**.
- Comentarios explicativos y documentación de trabajo, **en español**.
- Fuentes documentales de texto en UTF-8.
- Preservar la procedencia y las atribuciones de los recursos propios y externos.

## Premisas permanentes

Premises 1 to 10 come from `docs/PROJECT.md`, section "Premisas permanentes".
Premises 11 to 20 were added on request by the author.

1. Code, identifiers, README, and all documentation in English. Explanatory
   comments inside code remain in Spanish, so the author and Spanish-speaking
   collaborators understand the intent of each block.
2. Preferir funciones nativas estables de GZDoom 4.14.2. Mantener una sola fuente
   autoritativa para datos y una arquitectura compartida entre armas y actores.
3. El producto final debe ser independiente: no distribuir assets de Doom.
   Mantener procedencia, atribuciones y modificaciones de los recursos propios
   o externos. Las dependencias de desarrollo no equivalen a autorización de distribución.
4. No inventar valores de balance, recetas, historia ni decisiones pendientes.
   El diseño del autor y sus correcciones posteriores fijan esos datos.
5. Proteger lo ya aceptado y validar sólo lo afectado por una revisión.
   Distinguir análisis estático, prueba aislada del motor y aceptación del autor.
6. Entregar únicamente archivos nuevos/modificados para copiar y pegar, más
   un TXT con aplicación y pruebas necesarias; sin instaladores del parche.
   No incluir IWAD, ejecutables, fixtures de prueba ni un PK3 completo como si
   fuera la base definitiva cuando sólo se dispone de un delta.
7. **Documentación consolidada y actualizada en cada parche.** README.md es la
   entrada general y se revisa con cada entrega. Mantener estos cinco archivos
   de `docs/`; integrar temas nuevos en sus capítulos antes de crear otro archivo.
   Un nuevo documento permanente sólo se justifica si el autor lo requiere.
8. Cada entrega actualiza versión, estado real, decisiones, próximos pasos y
   resultados de pruebas en el mismo cambio. No duplicar el estado entre un
   README por parche y varios informes temáticos. Las instrucciones temporales
   del ZIP quedan fuera de la instalación; las antiguas van al historial.
9. Conservar historia y contenido único. Antes de retirar un documento, integrar
   su información vigente y preservar el original. No eliminar silenciosamente
   archivos locales ni mantener requisitos obsoletos como instrucciones actuales.
10. **Carpetas con una responsabilidad clara.** Antes de retirar archivos,
    comprobar consumidores y procedencia. Conservar fuentes útiles en assets,
    empaquetar sólo src y respaldar retiradas conocidas. El TXT de pruebas
    de cada entrega no se acumula en los cinco documentos activos. V5.0 reorganiza el
    código mediante cambios pequeños con compatibilidad de guardado.
11. Todo cambio debe ser trazable a un issue o tarea.
12. Ningún agente borra archivos sin autorización explícita.
13. Los generadores deben ser deterministas (misma entrada, misma salida
    byte a byte).
14. One model per task. Routine tasks → economical model (DeepSeek).
    Architecture, narrative, or complex review → advanced model
    (ChatGPT Pro). Document in AGENTS.md which model is expected for each
    task type.
15. Saves always migratable. No change may invalidate an existing save
    without explicit, tested, and reversible migration. Schema changes
    carry a revision number and idempotent migration logic.
16. Data outside logic. Balance values, recipes, coordinates, names, and
    texts live in data or documents, never hardcoded in logic. If an agent
    needs a number that is not in the documents, it must ask, not invent it.
17. One change, one reason. Each commit or PR addresses a single purpose.
    Visual changes, balance changes, and code changes are not mixed, so
    that only what failed can be reverted.
18. Cross-verification between AIs. When possible, one AI reviews another's
    work. DeepSeek reviews ChatGPT's code; ChatGPT reviews DeepSeek's
    design. Reduces errors without the author having to review every line.
19. Documentation is the contract. If code and documentation differ, the
    documentation prevails until updated. An agent that finds a discrepancy
    must report it, not silently "fix" the code to match.
20. Issues are the unit of work. Every significant change (code, balance,
    document, map) originates in an issue describing the problem or
    objective, reference documents, explicit scope, and acceptance criteria.
    A PR without a linked issue is not reviewed.

## Flujo de trabajo esperado

1. **Leer contexto.** Empezar por `docs/CONTEXT.md`, luego el documento canónico
   correspondiente a la tarea según la tabla anterior.
2. **Revisar impacto.** Comprobar si el cambio afecta a sistemas ya aceptados;
   no reabrir lo aprobado sin motivo y no inventar valores pendientes.
3. **Implementar cambios mínimos.** Modificar solo lo necesario y solo archivos
   nuevos o afectados.
4. **Actualizar documentación.** Reflejar versión, estado, decisiones y
   resultados de pruebas en el mismo cambio.
5. **Reportar pruebas.** Separar análisis estático, prueba aislada en el motor
   y aceptación del autor; indicar qué quedó pendiente.
