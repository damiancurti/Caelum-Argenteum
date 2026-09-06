# Caelum Argenteum — Iconografía corregida y tiers V4.32.0d

## 1. Entrega integrada

La entrega `Caelum_Argenteum_iconos_corregidos_tiers_2_3_ENTREGA(1).zip` se
integró sin redibujar ni recomprimir sus PNG. El árbol final contiene 255
iconos: 157 bases, 49 variantes T2 y 49 variantes T3. Frente a V4.32.0c, 23
archivos base cambian por sus correcciones suministradas y 98 archivos de tier
son nuevos.

Las 49 familias con tier se distribuyen así:

| Familia | Variantes base | T2 | T3 |
| --- | ---: | ---: | ---: |
| Armas | 20 | 20 | 20 |
| Armaduras por tipo/ranura | 16 | 16 | 16 |
| Escudos | 4 | 4 | 4 |
| Amuletos | 4 | 4 | 4 |
| Sellos | 5 | 5 | 5 |
| **Total** | **49** | **49** | **49** |

Los 252 iconos generales son PNG RGBA de 128×128. Los tres iconos monetarios
permanecen RGBA de 64×64. La auditoría compara cada archivo del árbol runtime
con los SHA-256 del proveedor.

## 2. Resolución en interfaz

`CaelumIconResolver` centraliza la convención:

```text
T1 -> nombre.png
T2 -> nombre_t2.png
T3 -> nombre_t3.png
```

El resolver se aplica a la selección de equipo del Inventario, la vista previa
de fabricación, los iconos dinámicos de amuletos y sellos y la presentación del
arma activa. Tipo, ranura y tier provienen de la instancia seleccionada o de la
receta actual; el arte no altera estadísticas, recetas, peso ni durabilidad.

## 3. Bases corregidas

Las correcciones reemplazan 17 iconos generales —armadura media, campana,
libro, botas mágicas, munición de carabina, ballesta, daga, bebida energética,
guanteletes gigantes, hachuela, arco largo, botiquín, escudo mágico, bastón,
estatuilla, espada y hacha de guerra— y seis componentes: hoja, lingote de
cobre, armazón largo, punta, cuerda de arco reforzada y correa reforzada.

Ningún sprite de mundo, mapa, sonido o valor jugable fue cambiado por esta
entrega.
