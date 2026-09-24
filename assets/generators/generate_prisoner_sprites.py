#!/usr/bin/env python3
"""Deterministic recolored prisoner sprites for issue #13 / 4.36.7.

Reuses every accepted mansion actor pose (idle, chase, combat and rest) for
Caella, Ronnie, Rulo and Argento and produces four distinguishable prisoner
appearances by recolouring only the materials assigned per faction (hair/fur,
cloak or cloth) through muted luminance ramps. No new character model or
replacement illustration is created: every output pixel keeps the source alpha,
unassigned materials such as skin and metallic accessories keep their accepted
RGB value, and assigned materials preserve the source silhouette, poses and
shading detail.

Outputs are byte-for-byte deterministic for the same committed source files and
palette data. The script also appends the matching Sprite block to src/TEXTURES
exactly once (guarded by a marker comment, replacing an older prisoner block)
and writes review evidence under assets/validation_4367/.
"""
from pathlib import Path
import colorsys
import json
import shutil

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SPRITE_ROOT = ROOT / "src" / "sprites" / "caelum"
REST_ROOT = SPRITE_ROOT / "rest"
EVIDENCE = ROOT / "assets" / "validation_4367"
TEXTURES_PATH = ROOT / "src" / "TEXTURES"
TEXTURES_MARKER = "// CAELUM_PRISONERS_V2"

# Source actor sprite prefixes by character and pose role. The accepted source
# actors consume these files in the same order used by the generated ZScript.
SOURCE_PREFIXES = {
    "caella": {"idle": "CAID", "chase": "CARN", "combat": "CAEL", "rest": "RSCA"},
    "ronnie": {"idle": "ROID", "chase": "RORN", "combat": "RONI", "rest": "RSRO"},
    "rulo": {"idle": "RUID", "chase": "RURN", "combat": "RULO", "rest": "RSRU"},
    "argento": {"idle": "ARID", "chase": "ARRN", "combat": "ARGO", "rest": "RSAR"},
}

# Output sprite prefixes by faction and pose role. Four characters keep GZDoom
# sprite names valid; the idle prefix is also the visual identity used in state
# blocks and the author-facing palette map.
OUTPUT_PREFIXES = {
    "unitario": {"idle": "PUNI", "chase": "PUNC", "combat": "PUNL", "rest": "PUNR"},
    "federal": {"idle": "PFED", "chase": "PFEC", "combat": "PFEL", "rest": "PFER"},
    "bestia": {"idle": "PBES", "chase": "PBRN", "combat": "PBEL", "rest": "PBER"},
    "tarot": {"idle": "PTAR", "chase": "PTRN", "combat": "PTEL", "rest": "PTER"},
}

# Faction material palettes. Each stop is (luminance 0..1, (R, G, B)). Luminance
# uses the Rec. 601 luma weights so accepted shading is preserved while the hue
# is replaced only on the recoloured materials. Skin, metallic accessories and
# explicitly kept cloth are left untouched. Values are author-facing data, not
# gameplay constants.
PRISONERS = [
    {
        "faction": "unitario",
        "display_name": "Leonor Benitez",
        "source_char": "caella",
        "source_prefix": "CAID",
        "sprite_prefix": "PUNI",
        "material_policy": "Recolour black hair and navy cloak to muted celeste; keep olive skin, cream sleeves/skirt and brown leather.",
        "primary": {
            "name": "muted celeste",
            "stops": [
                (0.00, (10, 12, 18)),
                (0.30, (40, 78, 104)),
                (0.62, (110, 156, 180)),
                (1.00, (200, 226, 236)),
            ],
        },
        "secondary": None,
    },
    {
        "faction": "federal",
        "display_name": "Rufino Acosta",
        "source_char": "ronnie",
        "source_prefix": "ROID",
        "sprite_prefix": "PFED",
        "material_policy": "Recolour silver-white hair and navy coat to muted punzo red; keep lavender skin, cream sleeves and brown leather.",
        "primary": {
            "name": "muted punzo red",
            "stops": [
                (0.00, (18, 9, 9)),
                (0.30, (96, 24, 26)),
                (0.62, (168, 50, 52)),
                (1.00, (224, 104, 102)),
            ],
        },
        "secondary": None,
    },
    {
        "faction": "bestia",
        "display_name": "Santos Barrera",
        "source_char": "rulo",
        "source_prefix": "RUID",
        "sprite_prefix": "PBES",
        "material_policy": "Recolour shaggy fur toward black and brown, olive waist cloth toward green; keep iron armor and the dark red front panel.",
        "primary": {
            "name": "muted black/brown fur",
            "stops": [
                (0.00, (8, 8, 6)),
                (0.25, (34, 26, 18)),
                (0.55, (78, 54, 30)),
                (0.80, (124, 88, 52)),
                (1.00, (168, 126, 82)),
            ],
        },
        "secondary": {
            "name": "muted green cloth",
            "stops": [
                (0.00, (10, 12, 8)),
                (0.35, (40, 58, 28)),
                (0.70, (70, 94, 50)),
                (1.00, (112, 142, 84)),
            ],
        },
    },
    {
        "faction": "tarot",
        "display_name": "Leandro Farias",
        "source_char": "argento",
        "source_prefix": "ARID",
        "sprite_prefix": "PTAR",
        "material_policy": "Recolour navy coat toward black with silver highlights and gray hair toward silver; keep gold motifs, cream tabard and brown leather.",
        "primary": {
            "name": "black coat with silver highlights",
            "stops": [
                (0.00, (8, 8, 10)),
                (0.30, (20, 22, 26)),
                (0.60, (58, 64, 70)),
                (0.85, (128, 136, 140)),
                (1.00, (190, 198, 202)),
            ],
        },
        "secondary": {
            "name": "silver hair",
            "stops": [
                (0.00, (52, 54, 56)),
                (0.40, (118, 122, 126)),
                (0.75, (176, 180, 184)),
                (1.00, (224, 228, 232)),
            ],
        },
    },
]

CANVAS = 256
GROUND_OFFSET = 244


def _luma(rgb):
    return 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]


def build_lut(stops):
    """Return a 256-entry list of (r, g, b) for each integer luma value."""
    ordered = sorted(stops, key=lambda item: item[0])
    lut = []
    for value in range(256):
        t = value / 255.0
        if t <= ordered[0][0]:
            color = ordered[0][1]
        elif t >= ordered[-1][0]:
            color = ordered[-1][1]
        else:
            for index in range(len(ordered) - 1):
                left = ordered[index]
                right = ordered[index + 1]
                if left[0] <= t <= right[0]:
                    span = right[0] - left[0]
                    ratio = 0.0 if span == 0.0 else (t - left[0]) / span
                    color = tuple(
                        int(round(left[1][channel] + ratio * (right[1][channel] - left[1][channel])))
                        for channel in range(3)
                    )
                    break
        lut.append(color)
    return lut


def classify_material(source_char, rgb):
    """Return "keep", "primary" or "secondary" for one opaque source pixel.

    The ranges are intentionally conservative: only the main hair/fur/cloth
    surfaces are recoloured, while skin, cream/leather accessories and metallic
    details retain the accepted mansion artwork. Antialiased edge pixels that do
    not match a range are kept, preserving the source silhouette.
    """
    h, s, v = colorsys.rgb_to_hsv(*(channel / 255.0 for channel in rgb))
    hue = h * 360.0

    if source_char == "caella":
        if 15.0 <= hue <= 75.0 and 0.12 <= s <= 0.75 and v >= 0.40:
            return "keep"
        if 5.0 <= hue <= 55.0 and s >= 0.35 and 0.12 <= v <= 0.65:
            return "keep"
        if 190.0 <= hue <= 280.0 and s >= 0.18 and v < 0.85:
            return "primary"
        if v < 0.24:
            return "primary"
        return "keep"

    if source_char == "ronnie":
        if 220.0 <= hue <= 330.0 and v >= 0.45 and s <= 0.70:
            return "keep"
        if 15.0 <= hue <= 70.0 and s <= 0.55 and v >= 0.55:
            return "keep"
        if 5.0 <= hue <= 55.0 and s >= 0.30 and v < 0.65:
            return "keep"
        if s < 0.18 and v >= 0.70:
            return "primary"
        if 195.0 <= hue <= 280.0 and v < 0.45:
            return "primary"
        return "keep"

    if source_char == "rulo":
        if s < 0.18 and 0.30 <= v <= 0.80:
            return "keep"
        if (hue < 18.0 or hue >= 345.0) and s >= 0.45 and v < 0.55:
            return "keep"
        if 55.0 <= hue <= 120.0 and s >= 0.18 and v < 0.80:
            return "secondary"
        if 5.0 <= hue <= 55.0 and s >= 0.20:
            return "primary"
        return "keep"

    if source_char == "argento":
        if 35.0 <= hue <= 75.0 and s >= 0.45 and v >= 0.40:
            return "keep"
        if 15.0 <= hue <= 75.0 and s <= 0.45 and v >= 0.55:
            return "keep"
        if 5.0 <= hue <= 55.0 and s >= 0.28 and v < 0.62:
            return "keep"
        if 5.0 <= hue <= 50.0 and 0.25 <= s <= 0.70 and 0.35 <= v <= 0.75:
            return "keep"
        if s < 0.20 and v >= 0.50:
            return "secondary"
        if 195.0 <= hue <= 280.0 and v < 0.45:
            return "primary"
        return "keep"

    return "keep"


def recolor_image(source_path, prisoner):
    image = Image.open(source_path).convert("RGBA")
    primary_lut = build_lut(prisoner["primary"]["stops"])
    secondary = prisoner.get("secondary")
    secondary_lut = build_lut(secondary["stops"]) if secondary else primary_lut
    pixels = list(image.getdata())
    recolored = []
    for r, g, b, a in pixels:
        if a == 0:
            recolored.append((0, 0, 0, 0))
            continue
        material = classify_material(prisoner["source_char"], (r, g, b))
        if material == "keep":
            recolored.append((r, g, b, a))
            continue
        lut = primary_lut if material == "primary" else secondary_lut
        index = max(0, min(255, int(round(_luma((r, g, b))))))
        color = lut[index]
        recolored.append((color[0], color[1], color[2], a))
    image.putdata(recolored)
    return image


def source_path_for(prisoner, role, filename):
    if role == "rest":
        return REST_ROOT / prisoner["source_char"] / filename
    return SPRITE_ROOT / prisoner["source_char"] / filename


def collect_source_files(prisoner):
    """Return (role, source_prefix, source_filename) in stable generation order."""
    result = []
    for role, source_prefix in SOURCE_PREFIXES[prisoner["source_char"]].items():
        directory = REST_ROOT / prisoner["source_char"] if role == "rest" else SPRITE_ROOT / prisoner["source_char"]
        for source_path in sorted(directory.glob(source_prefix + "*.png")):
            result.append((role, source_prefix, source_path.name))
    return result


def output_name(prisoner, role, source_prefix, source_filename):
    prefix = OUTPUT_PREFIXES[prisoner["faction"]][role]
    return prefix + source_filename[len(source_prefix):].removesuffix(".png")


def texture_lines(prisoner, sprite_name):
    path = f"sprites/caelum/prisoners/{prisoner['faction']}/{sprite_name}.png"
    return (
        f'Sprite "{sprite_name}", {CANVAS}, {CANVAS} '
        f"{{ Offset 128, {GROUND_OFFSET} Patch \"{path}\", 0, 0 }}"
    )


def strip_previous_prisoner_block(text):
    """Remove a previous prisoner sprite block so regeneration stays idempotent."""
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.startswith("// CAELUM_PRISONERS"):
            return "".join(lines[:index])
    return text


def ensure_textures_block(generated_by_faction):
    existing = strip_previous_prisoner_block(
        TEXTURES_PATH.read_text(encoding="utf-8")
    ).rstrip("\n")
    lines = [
        TEXTURES_MARKER + " - recolored prisoner appearances (#13, 4.36.7).",
        "// Reuses every accepted mansion actor pose with the deterministic",
        "// faction palette ramps recorded in assets/validation_4367/.",
    ]
    for prisoner in PRISONERS:
        lines.append(
            f"// {prisoner['source_char'].title()} actor poses -> {prisoner['faction']} prisoner."
        )
        for sprite_name in generated_by_faction[prisoner["faction"]]:
            lines.append(texture_lines(prisoner, sprite_name))
    TEXTURES_PATH.write_text(
        existing + "\n\n" + "\n".join(lines) + "\n",
        encoding="utf-8",
    )


def write_evidence(generated_by_faction):
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    palette_map = []
    for prisoner in PRISONERS:
        palette_map.append(
            {
                "faction": prisoner["faction"],
                "display_name": prisoner["display_name"],
                "source_char": prisoner["source_char"],
                "source_prefix": prisoner["source_prefix"],
                "sprite_prefix": prisoner["sprite_prefix"],
                "prefix_map": OUTPUT_PREFIXES[prisoner["faction"]],
                "material_policy": prisoner["material_policy"],
                "primary": prisoner["primary"],
                "secondary": prisoner.get("secondary"),
                "frames_generated": len(generated_by_faction[prisoner["faction"]]),
            }
        )
    (EVIDENCE / "PALETTE_MAP.json").write_text(
        json.dumps(palette_map, indent=2) + "\n", encoding="utf-8"
    )

    try:
        label_font = ImageFont.load_default(size=18)
    except TypeError:
        label_font = ImageFont.load_default()

    # Representative before/after sheet: front idle pose for each faction, the
    # same native comparison used for author review alongside engine captures.
    cell_w = CANVAS * 2 + 16
    cell_h = CANVAS + 44
    sheet = Image.new("RGB", (cell_w, cell_h * len(PRISONERS)), (46, 50, 58))
    draw = ImageDraw.Draw(sheet)
    for row_index, prisoner in enumerate(PRISONERS):
        source = Image.open(
            SPRITE_ROOT / prisoner["source_char"] / f"{prisoner['source_prefix']}A1.png"
        ).convert("RGBA")
        recolored = Image.open(
            SPRITE_ROOT / "prisoners" / prisoner["faction"] / f"{prisoner['sprite_prefix']}A1.png"
        ).convert("RGBA")
        background = Image.new("RGBA", source.size, (30, 33, 40, 255))
        left = background.copy()
        left.alpha_composite(source)
        right = background.copy()
        right.alpha_composite(recolored)
        top = row_index * cell_h
        draw.text(
            (4, top + 4),
            f"{prisoner['source_char'].title()} source -> {prisoner['faction']} prisoner",
            fill=(220, 226, 232),
            font=label_font,
        )
        sheet.paste(left.convert("RGB"), (0, top + 32))
        sheet.paste(right.convert("RGB"), (CANVAS + 16, top + 32))
    sheet.save(EVIDENCE / "before_after.png")

    results = {
        "version": "4.36.7",
        "issue": 13,
        "sprites_generated": sum(
            len(generated_by_faction[prisoner["faction"]]) for prisoner in PRISONERS
        ),
        "frames_by_faction": {
            prisoner["faction"]: len(generated_by_faction[prisoner["faction"]])
            for prisoner in PRISONERS
        },
        "palette_map": "PALETTE_MAP.json",
        "before_after": "before_after.png",
        "textures_marker": TEXTURES_MARKER,
    }
    (EVIDENCE / "RESULTS.json").write_text(
        json.dumps(results, indent=2) + "\n", encoding="utf-8"
    )


def main():
    generated_by_faction = {}
    for prisoner in PRISONERS:
        output_dir = SPRITE_ROOT / "prisoners" / prisoner["faction"]
        shutil.rmtree(output_dir, ignore_errors=True)
        output_dir.mkdir(parents=True, exist_ok=True)
        names = []
        for role, source_prefix, source_filename in collect_source_files(prisoner):
            sprite_name = output_name(prisoner, role, source_prefix, source_filename)
            recolored = recolor_image(
                source_path_for(prisoner, role, source_filename),
                prisoner,
            )
            recolored.save(output_dir / f"{sprite_name}.png")
            names.append(sprite_name)
        generated_by_faction[prisoner["faction"]] = names
    ensure_textures_block(generated_by_faction)
    write_evidence(generated_by_faction)
    print(
        "generated",
        sum(len(names) for names in generated_by_faction.values()),
        "prisoner sprites",
    )
    print(f"TEXTURES block: {TEXTURES_MARKER}")


if __name__ == "__main__":
    main()
