"""Open the silent gallery, real melee stage and death roster in one GZDoom session."""

import argparse
import ctypes
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE.parent / "validation_v5_18_13"))
from check_slam import CODE, stage_wad

EXTRA = [
    ("Palomo", "CaelumPalomo"),
    ("Palomo de la cacería", "CaelumHuntPalomo"),
    ("Autómata del Tarot", "CaelumTarotAutomaton"),
    ("Toro", "CaelumBull"),
    ("Caella", "CaelumCaella"),
    ("Ronnie", "CaelumRonnie"),
    ("Rulo", "CaelumRulo"),
    ("Argento", "CaelumArgento"),
    ("Preso unitario", "CaelumPrisonerUnitario"),
    ("Preso federal", "CaelumPrisonerFederal"),
    ("Preso bestia", "CaelumPrisonerBestia"),
    ("Preso del Tarot", "CaelumPrisonerTarot"),
    ("Defensor del puerto", "CaelumPortDefender"),
    ("Subcapitán", "CaelumCompanionSubcaptain"),
    ("Bandido", "CaelumTravelBandit"),
    ("Bandido con carabina", "CaelumTravelCarbineBandit"),
    ("Espíritu del Tarot", "CaelumTarotExampleSpirit"),
    ("Espíritu informante", "CaelumHuntInformativeSpirit"),
    ("Clon lunar", "CaelumTarotClone"),
    ("Zupay invocado", "CaelumSummonedZupay"),
    ("Guardián", "CaelumHuntGuardian"),
]


def fixture(out):
    subprocess.run(
        [
            sys.executable,
            "-X",
            "utf8",
            str(HERE.parent / "validation_v5_18_10/build_gallery.py"),
            "--output",
            str(out),
        ],
        check=True,
    )
    gallery = out / "galeria.pk3"
    roster = json.loads((out / "roster.json").read_bytes())
    families = [r for r in roster if r["group"] == "Jugadores"]
    with zipfile.ZipFile(gallery) as base:
        models = base.read("MODELDEF").decode()
    source = [CODE]
    definitions = []
    candidates = []
    for i, r in enumerate(families):
        cls = "FallFamily" + str(i)
        block = re.search(r"Model " + r["actor"] + r"\s*\{([^}]+)\}", models)[1]
        slots = re.findall(r"FrameIndex D300 A (\d+) 0", block)
        assert slots
        for letter, pose in zip("BCDE", (12, 13, 14, 15)):
            for slot in slots:
                block += f"    FrameIndex D300 {letter} {slot} {pose}\n"
        definitions.append("Model " + cls + "\n{" + block + "}\n")
        source.append(
            f"class {cls} : {r['actor']} {{ States {{ Falling: D300 B 8; D300 C 8; D300 D 16; D300 E -1;Stop; }} }}"
        )
        candidates.append((r["label"], cls))
    candidates.extend(
        (r["label"], r["source"])
        for r in roster
        if r["source"] in ("CaelumMandinga", "CaelumZupayColossus", "CaelumGiantRat")
    )
    candidates.extend(EXTRA)
    candidates.extend(
        (r["label"], r["source"]) for r in roster if re.fullmatch(r"CaelumBestiary\d+", r["source"])
    )
    code = (
        (HERE / "death_stage.zs")
        .read_text("utf8")
        .replace("TOTAL", str(len(candidates)))
        .replace("FAMILY_COUNT", str(len(families)))
    )
    source.append(
        code.replace(
            "CAPTIONS", ",".join(json.dumps(label, ensure_ascii=False) for label, _ in candidates)
        ).replace("CLASSES", ",".join("'" + actor + "'" for _, actor in candidates))
    )
    patch = out / "movimiento.pk3"
    with zipfile.ZipFile(patch, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("ZSCRIPT", "\n".join(source).encode())
        z.writestr("MODELDEF", "\n".join(definitions))
        z.writestr("maps/MOTION.wad", stage_wad())
        z.writestr("maps/CAIDAS.wad", stage_wad())
        z.writestr(
            "MAPINFO",
            'gameinfo { AddEventHandlers = "SlamInspection", "DeathInspection" }\nmap MOTION "Golpe de Zupay" { nointermission }\nmap CAIDAS "Caídas" { nointermission }'.encode(),
        )
    (out / "caidas.txt").write_text(
        "\n".join(f"{i:2d}  {label}" for i, (label, _) in enumerate(candidates, 1)), encoding="utf8"
    )
    return gallery, patch, candidates


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path, default=ROOT / "build/galeria-movimiento")
    p.add_argument("--game", type=Path)
    p.add_argument("--map", choices=["GALERIA", "MOTION", "CAIDAS"], default="GALERIA")
    p.add_argument("--check", action="store_true")
    p.add_argument("--sample", nargs="+", type=int)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    version = re.search(
        r"Current release:\s*(\d+\.\d+\.\d+[a-z]?)", (ROOT / "README.md").read_text("utf8")
    )[1]
    folder = ROOT / "build" / f"CaelumArgenteum-{version}-prologue"
    game = args.game or folder / "caelum_argenteum.ipk3"
    if not game.is_file() and args.game is None:
        subprocess.run(
            [sys.executable, str(ROOT / "build_release.py"), "--output", str(folder)], check=True
        )
    game = game.resolve(strict=True)
    gallery, patch, rows = fixture(out)
    cfg = [
        "snd_mastervolume 0",
        "i_pauseinbackground false",
        "vid_activeinbackground true",
        "vid_lowerinbackground false",
        "screenblocks 12",
        "show_messages false",
        "crosshair 0",
        "r_drawplayersprites false",
        "ca_bull_3d true",
        'bind f6 "map GALERIA"',
        'bind f7 "map CAIDAS"',
        'bind f8 "map MOTION"',
        'bind r "netevent fall_repeat"',
        'bind pgup "netevent fila_anterior"',
        'bind pgdn "netevent fila_siguiente"',
        "bind w +forward",
        "bind s +back",
        "bind a +moveleft",
        "bind d +moveright",
        "freelook true",
        "vid_maxfps 60",
    ]
    roster = json.loads((out / "roster.json").read_bytes())
    for k, row in enumerate(
        (
            1,
            15,
            22,
            24,
            next(r["station"] for r in roster if r["group"] == "Vestuario"),
            next(r["station"] for r in roster if r["group"] == "Equipo"),
        ),
        1,
    ):
        cfg.append(f'bind {k} "netevent fila_puesto {row}"')
    requested = args.sample or list(range(1, len(rows) + 1))
    if args.check:
        cfg.append("wait 125; exec row0.cfg")
        for i, n in enumerate(requested):
            if not 1 <= n <= len(rows):
                p.error("Station out of range")
            commands = [
                f"netevent fall_slot {n}",
                "wait 15",
                f"screenshot fall{n:03}-start.png",
                "wait 10",
                f"screenshot fall{n:03}-mid.png",
                "wait 23",
                f"screenshot fall{n:03}-end.png",
                "wait 40",
                "quit" if i == len(requested) - 1 else f"exec row{i + 1}.cfg",
            ]
            (out / f"row{i}.cfg").write_bytes(("; ".join(commands) + "\n").encode())
    (out / "view.cfg").write_bytes(("\n".join(cfg) + "\n").encode())
    print(
        "F6 Galería inmóvil   F7 Caídas   F8 Golpe de Zupay\nAvPág / RePág cambia de figura. R repite la caída. WASD y ratón para verla desde otro ángulo.\nSonido desactivado. Cierra GZDoom para volver a la terminal.",
        flush=True,
    )
    awake = ctypes.windll.kernel32.SetThreadExecutionState
    awake.argtypes = [ctypes.c_uint]
    awake.restype = ctypes.c_uint
    if not awake(0x80000001):
        raise OSError("Windows rejected the session sleep request")
    try:
        with (out / "console.log").open("wb") as f:
            result = subprocess.run(
                [
                    os.environ.get("GZDOOM_EXE", r"C:\Program Files (x86)\GZDoom\gzdoom.exe"),
                    "-nosound",
                    "-noautoload",
                    "-iwad",
                    str(game),
                    "-file",
                    str(gallery),
                    str(patch),
                    "-config",
                    str(out / "review.ini"),
                    "-window",
                    "+logfile",
                    str(out / "engine.log"),
                    "+map",
                    "CAIDAS" if args.check else args.map,
                    "+exec",
                    str(out / "view.cfg"),
                    "+language",
                    "es",
                ],
                cwd=out,
                stdout=f,
                stderr=f,
                timeout=(90 + 6 * len(requested)) if args.check else None,
            )
    finally:
        awake(0x80000000)
    log = (out / "engine.log").read_text("utf8", errors="replace")
    if result.returncode or re.search(
        r"VM execution aborted|Script error|Execution could not continue", log
    ):
        raise RuntimeError(log[-1400:])
    if args.check:
        counts = dict((int(n), int(k)) for n, k in re.findall(r"FALL end=(\d+) transitions=(\d+)", log))
        for n in requested:
            if counts.get(n, 0) < 3 or any(
                not (out / f"fall{n:03}-{phase}.png").is_file() for phase in ("start", "mid", "end")
            ):
                raise ValueError(f"Continuity or capture failure for station {n}: {counts.get(n)}")
        (out / "result.json").write_bytes(
            (json.dumps({rows[n - 1][1]: counts[n] for n in requested}, indent=2) + "\n").encode()
        )


if __name__ == "__main__":
    main()
