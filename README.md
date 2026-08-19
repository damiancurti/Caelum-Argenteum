# Caelum Argenteum

**Caelum Argenteum** es un videojuego independiente de fantasía oscura con estructura FPS-RPG, desarrollado sobre GZDoom/ZScript. El proyecto está pensado desde el inicio para poder distribuirse como obra independiente y no como un mod dependiente de recursos de Doom.

## Principios del proyecto

- **Independencia de assets:** la versión final no debe incluir sprites, sonidos, música, texturas, fuentes ni otros recursos de Doom o de terceros cuya licencia no permita su distribución. Los recursos provisionales usados durante desarrollo se consideran placeholders y deben poder reemplazarse sin romper la arquitectura del juego.
- **Funciones nativas primero:** cuando GZDoom/ZScript ya ofrece una solución estable, se prioriza esa vía antes que construir sistemas paralelos innecesarios.
- **Robustez antes que presentación:** una implementación simple, comprobable y mantenible tiene prioridad sobre una solución visualmente más compleja pero frágil.
- **Arquitectura escalable:** los sistemas comunes deben resolverse mediante clases base, datos compartidos y funciones reutilizables en lugar de duplicar lógica por cada arma, objeto o actor.
- **Gráficos modulares:** personajes y equipamiento visible se diseñarán por capas independientes cuando sea técnicamente razonable, evitando crear un sprite completo para cada combinación de personaje, arma, escudo o armadura.
- **Balance separado de lógica:** daño, costes, pesos, durabilidad y otros valores de diseño deben mantenerse separados de la lógica siempre que sea posible para facilitar balance y pruebas.
- **Sin valores arbitrarios:** si una implementación necesita una decisión de diseño aún no definida, debe consultarse al autor. Se pueden proponer valores y explicar sus consecuencias, pero no incorporarlos silenciosamente como definitivos.

## Convenciones de código

- Identificadores, clases, funciones y variables se escriben en **inglés**.
- Los comentarios explicativos dentro del código se escriben en **español**.
- Los comentarios deben explicar sistemas, decisiones, límites y puntos de extensión; no se busca comentar cada línea de forma redundante.
- El código debe ser legible y modificable por alguien que todavía está aprendiendo ZScript.
- Se evita introducir dependencias locales, rutas absolutas o soluciones que funcionen sólo en una máquina de desarrollo.

## Filosofía de implementación

El orden general de trabajo es:

1. **Arquitectura y mecánicas fundamentales.**
2. **Contenido construido sobre sistemas ya estables.**
3. **Presentación, pulido y expansión gráfica.**

Los sistemas confirmados como correctos se consideran estables. Un parche posterior debe evitar modificarlos salvo que exista una razón concreta, y cada cambio importante debe incluir pruebas de regresión sobre los sistemas relacionados.

Las actualizaciones se agrupan, cuando es razonable, en paquetes suficientemente grandes como para avanzar de forma significativa, pero con una batería de pruebas concreta que permita aislar fallos por subsistema.

## Estado de implementación

La documentación de diseño distingue entre funcionalidades **pendientes**, **programadas** y **comprobadas**. Escribir código no convierte automáticamente una función en comprobada: la validación en el motor forma parte del proceso.

Los errores de especificación se tratan como bugs. Los sistemas que funcionan según lo programado pero requieren ajustes de valores se consideran problemas de balance y deben corregirse sin reconstruir innecesariamente su arquitectura.

## Assets y licencias

Todo recurso incorporado al repositorio público debe tener un origen y una licencia compatibles con la distribución del juego. Antes de cualquier alpha o release público se realizará una auditoría de independencia para clasificar recursos propios, placeholders y recursos externos autorizados.

No debe existir una dependencia final de archivos pertenecientes a Doom u otras obras protegidas que no puedan redistribuirse legalmente con el juego.

## Repositorio público

Este proyecto está preparado para desarrollarse en un repositorio GitHub público. El código y la estructura del proyecto deben mantenerse comprensibles, reproducibles y aptos para revisión pública.

## Autor

**Damian Curti**
