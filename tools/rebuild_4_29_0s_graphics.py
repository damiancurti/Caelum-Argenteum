"""Unifica alias gráficos de objetos e incorpora los sprites de Domingo.

Los iconos 128x128 de ``graphics/caelum/icons`` son la fuente canónica tanto
para interfaz como para pickups. TEXTURES aporta escala y punto de apoyo al
uso en el mundo; no se mantienen segundas copias visuales de 64x64.
"""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEXTURES = ROOT / "src/TEXTURES"
PLAYER_MARKER = "// V4.29.0s - Domingo player sprites"
WORLD_MARKER = "// V4.29.0s - canonical 128x128 world pickup aliases"
PROJECTILE_MARKER = 'Sprite "XAIRA1"'
JEWELRY_MARKER = "// V4.23.4 jewelry"
PROJECTILE_SECTION = "// V4.23.5 - eight-direction physical projectile sprites."


PICKUPS = (
    ("CAMUA0", "ca_javelin.png", 114),
    ("CARRA0", "ca_arrow_ammo.png", 120),
    ("CBOLA0", "ca_bolt_ammo.png", 120),
    ("CCAAA0", "ca_carbine_ammo.png", 104),
    ("CAHVA0", "ca_armor_heavy.png", 119),
    ("CALIA0", "ca_armor_light.png", 120),
    ("CAMAA0", "ca_armor_magic.png", 120),
    ("CAMDA0", "ca_armor_medium.png", 120),
    ("CBHVA0", "ca_boots_heavy.png", 120),
    ("CBLTA0", "ca_boots_light.png", 120),
    ("CBMDA0", "ca_boots_medium.png", 120),
    ("CBOMA0", "ca_boots.png", 120),
    ("CGHVA0", "ca_gloves_heavy.png", 114),
    ("CGLTA0", "ca_gloves_light.png", 112),
    ("CGMDA0", "ca_gloves_medium.png", 108),
    ("CGMMA0", "ca_gloves.png", 120),
    ("CHEHA0", "ca_helmet.png", 120),
    ("CHLTA0", "ca_helmet_light.png", 120),
    ("CHMDA0", "ca_helmet_medium.png", 120),
    ("CHMGA0", "ca_helmet_magic.png", 120),
    ("CANIA0", "ca_anima_potion.png", 120),
    ("CENEA0", "ca_energy_drink.png", 108),
    ("CFOOA0", "ca_food_ration.png", 104),
    ("CMEDA0", "ca_medikit.png", 120),
    ("CWATA0", "ca_water_ration.png", 120),
    ("CKEYA0", "ca_key.png", 120),
    ("CSELA0", "ca_sealed_letter.png", 112),
    ("CTARA0", "ca_tarot_back.png", 120),
    ("CBUCA0", "ca_shield_buckler.png", 115),
    ("CSHKA0", "ca_shield_kite.png", 120),
    ("CSHMA0", "ca_shield_magic.png", 108),
    ("CSHTA0", "ca_shield_tower.png", 120),
    ("CBELA0", "ca_bell.png", 120),
    ("CBOOA0", "ca_book.png", 120),
    ("CSTAA0", "ca_statuette.png", 120),
    ("CSTFA0", "ca_staff.png", 120),
    ("CAXEA0", "ca_axe.png", 114),
    ("CDAGA0", "ca_dagger.png", 120),
    ("CFLAA0", "ca_flail.png", 109),
    ("CGAUA0", "ca_giant_gauntlets.png", 120),
    ("CGRSA0", "ca_greatsword.png", 120),
    ("CHALA0", "ca_halberd.png", 111),
    ("CHATA0", "ca_hatchet.png", 120),
    ("CJAVA0", "ca_javelin.png", 114),
    ("CMACA0", "ca_machete.png", 120),
    ("CSPRA0", "ca_spear.png", 113),
    ("CSWDA0", "ca_sword.png", 113),
    ("CWAXA0", "ca_war_axe.png", 120),
    ("CBOWA0", "ca_standard_bow.png", 120),
    ("CCARA0", "ca_carbine.png", 120),
    ("CCBWA0", "ca_crossbow.png", 120),
    ("CLBWA0", "ca_longbow.png", 120),
)


MATERIAL_NAMES = (
    "iron_ingot", "blade", "small_blade", "curved_blade", "long_blade",
    "broad_blade", "shaft", "frame", "long_frame", "weapon_head",
    "round_head", "plate", "round_plate", "kite_plate", "tower_plate",
    "magic_plate", "large_plate", "chainmail", "fabric", "leather",
    "fire_essence", "water_essence", "earth_essence", "wind_essence",
    "quintessence", "hilt", "long_hilt", "point", "handle", "long_handle",
    "bowstring", "reinforced_bowstring", "strap", "reinforced_strap",
    "barrel", "mechanism", "staff_base", "bell_base", "book_base",
    "statuette_base", "small_weapon_head", "chain", "wood", "silver_chain",
    "seal_base", "ruby_pendant", "sapphire_pendant", "emerald_pendant",
    "topaz_pendant", "ruby_gem", "sapphire_gem", "emerald_gem", "topaz_gem",
    "opal_brooch", "raw_ruby", "raw_sapphire", "raw_emerald", "raw_topaz",
    "raw_opal", "copper_ingot", "tin_ingot", "coal",
)

MATERIAL_BOTTOMS = (
    118, 113, 115, 119, 112, 120, 108, 115, 113, 120,
    117, 112, 116, 120, 120, 110, 110, 111, 98, 98,
    120, 119, 120, 120, 117, 114, 109, 111, 101, 105,
    113, 102, 104, 100, 110, 109, 120, 120, 120, 120,
    120, 120, 101, 120, 120, 120, 120, 120, 120, 113,
    110, 118, 112, 120, 113, 110, 118, 112, 109, 107,
    119, 102,
)

JEWELRY = (
    ("AMRBA0", "ca_amulet_ruby.png"),
    ("AMSAA0", "ca_amulet_sapphire.png"),
    ("AMEMA0", "ca_amulet_emerald.png"),
    ("AMTOA0", "ca_amulet_topaz.png"),
    ("SLFIA0", "ca_seal_fire.png"),
    ("SLWAA0", "ca_seal_water.png"),
    ("SLEAA0", "ca_seal_earth.png"),
    ("SLAIA0", "ca_seal_air.png"),
    ("SLQUA0", "ca_seal_quintessence.png"),
)


def sprite_line(name: str, path: str, bottom: int) -> str:
    return (
        f'Sprite "{name}", 128, 128 '
        f'{{ Offset 64, {bottom} Patch "{path}", 0, 0 }}'
    )


def build_player_section() -> list[str]:
    directory = ROOT / "src/sprites/caelum/domingo"
    frames = sorted(directory.glob("DOMI*.png"))
    if len(frames) != 39:
        raise ValueError(f"Domingo requiere 39 cuadros jugables, hay {len(frames)}")
    lines = [PLAYER_MARKER]
    for frame in frames:
        name = frame.stem
        lines.append(
            f'Sprite "{name}", 256, 256 '
            f'{{ Offset 128, 244 Patch "sprites/caelum/domingo/{frame.name}", 0, 0 }}'
        )
    return lines


def build_pickup_section() -> list[str]:
    lines = [WORLD_MARKER]
    icon_root = ROOT / "src/graphics/caelum/icons"
    for name, filename, bottom in PICKUPS:
        source = icon_root / filename
        if not source.is_file():
            raise ValueError(f"Falta el maestro gráfico {source}")
        lines.append(
            sprite_line(name, f"graphics/caelum/icons/{filename}", bottom)
        )

    if len(MATERIAL_NAMES) != 62 or len(MATERIAL_BOTTOMS) != 62:
        raise ValueError("La tabla de materiales debe contener 62 entradas")
    for index, (material, bottom) in enumerate(
        zip(MATERIAL_NAMES, MATERIAL_BOTTOMS)
    ):
        relative = f"materials/ca_material_{material}.png"
        source = icon_root / relative
        if not source.is_file():
            raise ValueError(f"Falta el maestro gráfico {source}")
        lines.append(
            sprite_line(
                f"M{index:03d}A0",
                f"graphics/caelum/icons/{relative}",
                bottom,
            )
        )
    return lines


def rebuild() -> bool:
    original = TEXTURES.read_text(encoding="utf-8")
    start_candidates = [
        position
        for marker in (PLAYER_MARKER, "// Caelum Argenteum 4.22.4c")
        if (position := original.find(marker)) >= 0
    ]
    if not start_candidates:
        raise ValueError("No se encontró el bloque heredado de pickups")
    start = min(start_candidates)
    end = original.index(PROJECTILE_MARKER, start)

    replacement = "\n".join(
        build_player_section()
        + [""]
        + build_pickup_section()
        + ["", ""]
    )
    rebuilt = original[:start] + replacement + original[end:]

    # M043--M061 estaban duplicados en una sección histórica. Sus alias ya
    # forman parte de la tabla canónica M000--M061 anterior.
    jewelry_start = rebuilt.index(JEWELRY_MARKER)
    jewelry_end = rebuilt.index(PROJECTILE_SECTION, jewelry_start)
    jewelry_lines = [JEWELRY_MARKER]
    for name, filename in JEWELRY:
        source = ROOT / "src/graphics/caelum/icons/jewelry" / filename
        if not source.is_file():
            raise ValueError(f"Falta el maestro gráfico {source}")
        jewelry_lines.append(
            sprite_line(
                name,
                f"graphics/caelum/icons/jewelry/{filename}",
                120,
            )
        )
    rebuilt = (
        rebuilt[:jewelry_start]
        + "\n".join(jewelry_lines)
        + "\n\n"
        + rebuilt[jewelry_end:]
    )

    if rebuilt == original:
        return False
    TEXTURES.write_text(rebuilt, encoding="utf-8", newline="\n")
    return True


if __name__ == "__main__":
    print(
        "TEXTURES: alias canónicos y Domingo reconstruidos"
        if rebuild()
        else "TEXTURES: alias canónicos y Domingo ya presentes"
    )
