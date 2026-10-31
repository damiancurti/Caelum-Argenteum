"""Run real, isolated GZDoom peers against the same cooperative-clock package (#436)."""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import re
from pathlib import Path
import struct
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).resolve().parent
ENGINE = Path("C:/Program Files (x86)/GZDoom/gzdoom.exe")
IWAD = Path("C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fixture(path: Path, peers: int, source_overlay: bool = False, persistence: bool = False, travel: bool = False) -> None:
    # Disposable geometry; installed development IWAD textures are not distributed.
    text = '''namespace="ZDoom";
vertex{x=-1024;y=-1024;} vertex{x=1024;y=-1024;}
vertex{x=1024;y=1024;} vertex{x=-1024;y=1024;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}
sidedef{sector=0;texturemiddle="STARTAN3";}
linedef{v1=1;v2=0;sidefront=0;blocking=true;}
linedef{v1=2;v2=1;sidefront=0;blocking=true;}
linedef{v1=3;v2=2;sidefront=0;blocking=true;}
linedef{v1=0;v2=3;sidefront=0;blocking=true;}
'''
    for player in range(peers):
        kind = player + 1 if player < 4 else 4001 + player - 4
        text += f"thing{{x={-448 + player * 128};y=0;type={kind};skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}}\n"
    lumps = [(b"MAP03", b""), (b"TEXTMAP", text.encode()), (b"ENDMAP", b"")]
    payload = b"".join(data for _, data in lumps)
    entries, offset = [], 12
    for name, data in lumps:
        entries.append(struct.pack("<ii8s", offset, len(data), name))
        offset += len(data)
    wad = struct.pack("<4sii", b"PWAD", len(lumps), 12 + len(payload)) + payload + b"".join(entries)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_STORED) as archive:
        for name, data in {
            "MAPINFO": ('gameinfo { AddEventHandlers = "CA436ClockProbe"' + (', "CaelumCooperativeTravelEvents"' if source_overlay else '') + ' }\n').encode(),
            "ZSCRIPT": b'version "4.14.2"\n#include "probe.zs"\n',
            "probe.zs": (SOURCE / ("travel_probe.zs" if travel else "persistence_probe.zs" if persistence else "clock_probe.zs")).read_bytes(),
            "maps/MAP03.wad": wad,
        }.items():
            entry = zipfile.ZipInfo(name, (2026, 10, 30, 0, 0, 0))
            archive.writestr(entry, data)
        if travel:
            archive.writestr("maps/TRESERV.wad", wad)
            archive.writestr("maps/CAH000.wad", wad)
        # Source overlays keep iterative native checks fast; final evidence uses
        # a full builder package with identical bytes for these members.
        if source_overlay:
            import subprocess
            names = subprocess.check_output(['git', 'diff', 'main', '--name-only', '--', 'src'], cwd=ROOT, text=True).splitlines()
            names += subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', 'src'], cwd=ROOT, text=True).splitlines()
            for name in sorted(set(names)):
                source = ROOT / name
                if source.is_file() and name not in ('src/MAPINFO', 'src/ZSCRIPT'):
                    data = source.read_bytes()
                    if source.name == 'CaelumWorldClock.zs':
                        data += b'\n#include "caelum/world/CaelumCooperativeTravel.zs"\n#include "caelum/world/CaelumCooperativeTravelMenu.zs"\n'
                    archive.writestr(name[4:], data)




def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--players", type=int, choices=(2, 4, 8), default=2)
    parser.add_argument("--port", type=int, default=29660)
    parser.add_argument("--source-overlay", action="store_true", help="Overlay edited clock/rest sources for iteration only")
    parser.add_argument("--persistence", action="store_true")
    parser.add_argument("--travel", action="store_true")
    parser.add_argument("--load-directory", type=Path, help="Read the common save from a prior isolated persistence run")
    args = parser.parse_args()
    runtime = args.runtime.resolve(strict=True)
    out = ROOT / "build/issue436" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    out.mkdir(parents=True)
    package = out / "checks.pk3"
    fixture(package, args.players, args.source_overlay, args.persistence, args.travel)
    processes, streams, commands = [], [], []
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    try:
        for index in range(args.players):
            peer = out / f"peer{index}"
            peer.mkdir()
            config = peer / "isolated.ini"
            commands_file = peer / "test.cfg"
            # Close remote peers first and the native arbitrator last. The separate
            # lifecycle probe must exercise unexpected arbitrator departure.
            quit_tic = 350 + (args.players - index) * 35
            commands_file.write_text("wait 105; netevent ca436_verify_reload; wait 245; quit\n" if args.load_directory and index==0 else f"wait {quit_tic}; quit\n", encoding="utf-8")
            config.write_text("[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\n"
                              "vid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\n"
                              "i_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\n"
                              "snd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=false\nlanguage=en\n", encoding="utf-8")
            network = ["-host", str(args.players), "-port", str(args.port), "-netmode", "0"] if index == 0 else [
                "-join", f"127.0.0.1:{args.port}", "-port", str(args.port + index)]
            entry = ["+map", "TRESERV" if args.travel else "MAP03"]
            if args.load_directory:
                saves = list((args.load_directory / f"peer{index}").glob("save*.zds"))
                if len(saves) != 1:
                    raise RuntimeError(f"Expected one preserved native save for peer {index}, found {len(saves)}")
                with (peer / "recovery.zds").open("xb") as recovery:
                    recovery.write(saves[0].resolve(strict=True).read_bytes())
                entry = ["-loadgame", "recovery.zds"]
            command = [str(ENGINE), "-noautoload", "-iwad", str(IWAD), "-file", str(runtime), str(package),
                       "-config", str(config), "-savedir", str(peer), "-window", "-width", "640", "-height", "480",
                       "-rngseed", "436", *network, "+logfile", str(peer / "engine.log"), *entry,
                       "+exec", str(commands_file)]
            commands.append(command)
            stream = (peer / "process.log").open("wb")
            streams.append(stream)
            processes.append(subprocess.Popen(command, cwd=peer, startupinfo=startup, stdout=stream, stderr=stream))
            time.sleep(0.3)
        print(f"Started {args.players} native peers: {out}", flush=True)
        deadline = time.monotonic() + 90
        while any(p.poll() is None for p in processes) and time.monotonic() < deadline:
            if any(any(token in log.read_text(encoding="utf-8", errors="replace") for token in ("Script error", "Attempt to redefine", "Unable to resolve", "compile errors", "Execution could not continue", "Cannot find savegame", "VM execution aborted"))
                   for log in out.glob("peer*/engine.log")):
                break
            time.sleep(0.2)
    finally:
        for process in processes:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=10)
        for stream in streams:
            stream.close()
    reports = []
    ordered_requests = []
    for index, process in enumerate(processes):
        log = out / f"peer{index}/engine.log"
        text = log.read_text(encoding="utf-8", errors="replace") if log.exists() else ""
        lines = text.splitlines()
        errors = [line for line in lines if any(token in line for token in
                  (" FAIL", "Script error", "Execution could not continue", "Cannot find savegame", "VM execution aborted", "desync", "out of sync"))]
        checks = [line for line in lines if line.startswith("CA436 ")]
        ordered_requests.append(re.findall(r"CA436 EVENT peer=\d+ sender=(\d+) serial=(\d+)", text))
        success = process.returncode == 0 and not errors and text.count("CA436 PASS") == (31 if args.travel else (6 if args.load_directory else 4) if args.persistence else 36) and text.count("CA436 RESULT") == 1
        reports.append({"peer": index, "exit": process.returncode, "passed": success, "checks": checks, "errors": errors})
    same_order = len(ordered_requests) == args.players and all(
        len(events) == args.players * (3 if args.travel else 1) and events == ordered_requests[0] for events in ordered_requests)
    if args.persistence:
        same_order = True
    result = {"persistence": args.persistence, "travel": args.travel, "load_directory": str(args.load_directory) if args.load_directory else None, "issue": 436, "baseline": "5.11.8", "source_overlay": args.source_overlay, "real_processes": args.players, "runtime_sha256": digest(runtime),
              "engine_sha256": digest(ENGINE), "iwad_sha256": digest(IWAD), "fixture_sha256": digest(package),
              "commands": commands, "peers": reports, "same_order": same_order,
              "passed": same_order and all(x["passed"] for x in reports)}
    (out / "results.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps({"directory": str(out), "passed": result["passed"], "peers": [{"peer": r["peer"], "passed": r["passed"], "pass_count": sum(" PASS " in x for x in r["checks"]), "errors": r["errors"], "failures": [x for x in r["checks"] if " FAIL " in x]} for r in reports]}, indent=2), flush=True)
    if not result["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
