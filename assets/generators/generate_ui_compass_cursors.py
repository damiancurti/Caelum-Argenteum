"""Build #87 SVG resources and native PNGs; requires resvg-py==0.5.0.

The generated logo adaptations are immutable inputs. Vector geometry fixes
the Sun's exact alternating ray count; resvg handles native-size conversion.
No timestamps, random values, external fonts or system-dependent assets.
"""
from pathlib import Path
import base64
import json
import struct
import zlib

import resvg_py

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/ui_compass_cursors"
OUTPUT = ROOT / "src/graphics"


def image_uri(name):
    return "data:image/png;base64," + base64.b64encode((SOURCE / name).read_bytes()).decode("ascii")


def png_offset(data, x, y):
    payload = struct.pack(">ii", x, y)
    chunk = b"grAb" + payload
    chunk = struct.pack(">I", len(payload)) + chunk + struct.pack(">I", zlib.crc32(chunk))
    return data[:33] + chunk + data[33:]


def render(svg, size):
    return resvg_py.svg_to_bytes(svg_string=svg, width=size, height=size, skip_system_fonts=True)


def main():
    spec = json.loads((SOURCE / "SPEC.json").read_text(encoding="utf-8"))
    sun, moon, palette = spec["sun"], spec["moon"], spec["palette"]
    center = sun["canvas"] / 2
    rays = []
    for i in range(sun["rays"]):
        kind = "straight" if i % 2 == 0 else "wavy"
        rays.append(f'<path data-ray="{i}" data-kind="{kind}" d="{sun[kind + "_path"]}" '
                    f'transform="rotate({i * 360 / sun["rays"]:g} {center:g} {center:g})" '
                    f'fill="url(#gold)" stroke="{palette["outline"]}" stroke-width="1.8"/>')
    factor = sun["face_radius"] / sun["face_source_radius"]
    face_x = center - sun["face_center"][0] * factor
    face_y = center - sun["face_center"][1] * factor
    raw = (SOURCE / "source_sun_face.png").read_bytes()
    width, height = struct.unpack(">II", raw[16:24])
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<defs><linearGradient id="gold" x1="0" y1="0" x2="1" y2="0">
<stop stop-color="{palette['shadow']}"/><stop offset=".48" stop-color="{palette['light']}"/>
<stop offset=".7" stop-color="{palette['gold']}"/><stop offset="1" stop-color="{palette['shadow']}"/>
</linearGradient><clipPath id="face"><circle cx="256" cy="256" r="{sun['face_radius']}"/></clipPath></defs>
{''.join(rays)}
<image href="{image_uri('source_sun_face.png')}" x="{face_x:.6f}" y="{face_y:.6f}"
width="{width * factor:.6f}" height="{height * factor:.6f}" clip-path="url(#face)"/>
<circle cx="256" cy="256" r="{sun['face_radius']}" fill="none" stroke="{palette['gold']}" stroke-width="2"/>
</svg>'''
    (SOURCE / "sun.svg").write_text(svg + "\n", encoding="utf-8", newline="\n")
    high_resolution = OUTPUT / "caelum/ui/ca_sun_selector.png"
    high_resolution.parent.mkdir(parents=True, exist_ok=True)
    high_resolution.write_bytes(render(svg, 128))
    frame = render(svg, sun["frame_size"])
    for name in ("M_SKULL1.png", "M_SKULL2.png"):
        (OUTPUT / name).write_bytes(frame)
    box = " ".join(str(v) for v in moon["viewbox"])
    moon_svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="{box}"><defs><mask id="clean"><rect width="1280" height="1280" fill="white"/><circle cx="784" cy="630" r="200" fill="black"/></mask></defs><image mask="url(#clean)" href="{image_uri("source_moon.png")}" width="1280" height="1280"/></svg>'
    (SOURCE / "moon.svg").write_text(moon_svg + "\n", encoding="utf-8", newline="\n")
    (OUTPUT / "cursor.png").write_bytes(png_offset(render(moon_svg, moon["size"]), *moon["hotspot"]))
    compass = spec["compass"]
    sun_uri = "data:image/png;base64," + base64.b64encode(high_resolution.read_bytes()).decode("ascii")
    leaves = []
    for x, y, angle in [(50, 111, -35), (37, 102, -25), (27, 90, -15),
                        (20, 76, 0), (19, 62, 10), (21, 48, 20), (26, 34, 30)]:
        leaves.append(f'<g transform="translate({x} {y}) rotate({angle})">'
                      '<path d="M0 0 C-8 -1 -13 -9 -6 -18 C1 -13 3 -6 0 0Z" '
                      'fill="url(#silver)" stroke="#172127" stroke-width=".8"/>'
                      '<path d="M0 0L-6 -17" fill="none" stroke="#e2e6e7" stroke-opacity=".65" stroke-width=".8"/>'
                      '</g>')
    rose = f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
<defs>
<linearGradient id="silver" x1="0" y1="0" x2="1" y2="1">
<stop stop-color="{compass['silver_shadow']}"/><stop offset=".28" stop-color="{compass['silver_highlight']}"/>
<stop offset=".48" stop-color="{compass['silver_mid']}"/><stop offset=".74" stop-color="{compass['silver_shadow']}"/>
<stop offset="1" stop-color="{compass['silver_highlight']}"/></linearGradient>
<radialGradient id="dial"><stop stop-color="#35302a"/><stop offset="1" stop-color="{compass['metal_dark']}"/></radialGradient>
<g id="laurel"><path d="M61 122 C17 108 8 59 30 17" fill="none" stroke="{compass['silver_shadow']}" stroke-width="3"/>
<path d="M61 121 C18 107 9 59 30 17" fill="none" stroke="{compass['silver_mid']}" stroke-width="1.2"/>
{''.join(leaves)}</g>
</defs>
<circle cx="64" cy="64" r="45" fill="#090e12" fill-opacity=".9"/>
<circle cx="64" cy="64" r="43" fill="url(#dial)" stroke="url(#silver)" stroke-width="3"/>
<circle cx="64" cy="64" r="40" fill="none" stroke="{palette['gold']}" stroke-opacity=".65" stroke-width="1"/>
<image href="{sun_uri}" x="24" y="24" width="80" height="80" opacity="{compass['sun_opacity']}"/>
<path d="M64 25V30 M64 98V103 M25 64H30 M98 64H103 M36 36L40 40 M88 88L92 92 M36 92L40 88 M88 40L92 36" stroke="{compass['silver_highlight']}" stroke-opacity=".65" stroke-width="1.4"/>
<use href="#laurel"/><use href="#laurel" transform="translate(128 0) scale(-1 1)"/>
<path d="M60 116L64 112L68 116L64 124Z" fill="url(#silver)" stroke="{compass['silver_shadow']}" stroke-width="1"/>
</svg>'''
    (SOURCE / "compass_rose.svg").write_text(rose + "\n", encoding="utf-8", newline="\n")
    target = OUTPUT / "caelum/ui/ca_compass_rose.png"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(render(rose, 128))
    print("Built 16 straight + 16 wavy rays, two Sun frames, 32px moon cursor and compass rose.")


if __name__ == "__main__":
    main()
