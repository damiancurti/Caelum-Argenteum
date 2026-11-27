# Campaign atlas and painted materials

[Download the working package as one ZIP](https://codeload.github.com/damiancurti/Caelum-Argenteum/zip/b2200b78aa9cdac45903fa4e9b085cb8992cd599) or [open the illustrated atlas](paquete/Atlas_Caelum_80_mapas.pdf). The ZIP contains only the reference materials in this folder's `paquete` directory. It includes the 80 map sheets, editable regional and map catalogues, 48 environment materials, 30 regional PK3s, the painted-model PK3, UV swatches and seven GZDoom comparisons.

## Using the package

Extract the ZIP. Add [the environment PK3](paquete/entornos/Caelum_48_materiales.pk3) and [the painted-model PK3](paquete/modelos/Caelum_pieles_pintadas.pk3) after the base game. The [authoring guide](paquete/README.md) covers Ultimate Doom Builder, the regional subsets, load order and the map registry. [Four layouts](paquete/referencias/Cuatro_recorridos_Caelum.png) and [the model comparison](paquete/referencias/Comparativa_modelos_Caelum.png) are available separately.

[Issue #906](https://github.com/damiancurti/Caelum-Argenteum/issues/906) tracks application. The playable count is three prologue maps (MAP01–MAP03), 75 further maps across Chapters I–III before the Moon and two lunar maps. The individual chapter totals in the original design sheets are editorial proposals. Use the approved [MAP02 and Barracas al Sud plans](https://github.com/damiancurti/Caelum-Argenteum/issues/454) when building those two levels.

## Original delivery

The working PDF retains all 43 pages, text, vectors, bookmarks and image dimensions. Its embedded color images have been recompressed. Every other original handoff file in the working package keeps its original bytes.

For the exact original PDF and ZIP, [download the archival copy](https://codeload.github.com/damiancurti/Caelum-Argenteum/zip/c5d9aba0b24f70d8ba5f7ba94363a39f82dd4636), extract it, then run the included `restore_original.py` with Python 3.8 or later (`py restore_original.py` on Windows, `python3 restore_original.py` on Linux or macOS). The script joins the ten parts and verifies the ZIP against SHA-256 before saving it. Extract the resulting `Caelum_mapas_y_texturas.zip` to access all 49 original files. The [checksums](original/SHA256SUMS.txt) cover that ZIP and its contents.

| Original file | SHA-256 |
| --- | --- |
| Caelum_mapas_y_texturas.zip | `23153b292a6ba6ac3e75f7e1d1b252e42b8eb5fe6513a4261f32f9821993aa29` |
| Atlas_Caelum_80_mapas.pdf | `daf67308ea15281fce7d766c1d75678fe67495b7862b0b65a24389e903cbcb62` |
