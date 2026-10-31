"""Run separate native peers against #438 production arenas and consent."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import struct
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path("C:/Program Files (x86)/GZDoom/gzdoom.exe")
IWAD = Path("C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD")


def fixture(target: Path, count: int, overlay: bool, hold: bool) -> None:
    # Only the departure map is disposable. Both arenas are production geometry.
    text = '''namespace="ZDoom";
vertex{x=-1024;y=-1024;} vertex{x=1024;y=-1024;} vertex{x=1024;y=1024;} vertex{x=-1024;y=1024;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}
sidedef{sector=0;texturemiddle="STARTAN3";}
linedef{v1=1;v2=0;sidefront=0;blocking=true;}
linedef{v1=2;v2=1;sidefront=0;blocking=true;}
linedef{v1=3;v2=2;sidefront=0;blocking=true;}
linedef{v1=0;v2=3;sidefront=0;blocking=true;}
'''
    for i in range(count):
        kind = i+1 if i<4 else 4001+i-4
        text += f"thing{{x={-448+i*128};y=0;type={kind};skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}}\n"
    lumps = [(b"MAP03", b""), (b"TEXTMAP", text.encode()), (b"ENDMAP", b"")]
    body = b"".join(data for _, data in lumps)
    offset, directory = 12, b""
    for name, data in lumps:
        directory += struct.pack("<ii8s", offset, len(data), name)
        offset += len(data)
    wad = struct.pack("<4sii", b"PWAD", len(lumps), 12+len(body))+body+directory
    with zipfile.ZipFile(target, "w", compression=zipfile.ZIP_STORED) as z:
        members = {"MAPINFO": b'gameinfo { AddEventHandlers="CA438Probe" }\n',
                   "ZSCRIPT": b'version "4.14.2"\n#include "probe.zs"\n',
                   "probe.zs": (Path(__file__).parent/"arena_probe.zs").read_bytes().replace(b"const HOLD_MATCH=0;",b"const HOLD_MATCH=1;" if hold else b"const HOLD_MATCH=0;"), "maps/MAP03.wad": wad}
        if overlay:
            changed = subprocess.check_output(["git", "-c", "core.safecrlf=false", "diff", "HEAD", "--name-only", "--", "src"], cwd=ROOT, text=True).splitlines()
            changed += subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard", "src"], cwd=ROOT, text=True).splitlines()
            for name in sorted(set(changed)):
                if name not in ("src/MAPINFO", "src/ZSCRIPT"):
                    members[name[4:]] = (ROOT/name).read_bytes()
        for name, data in members.items():
            z.writestr(zipfile.ZipInfo(name, (2026,10,31,0,0,0)), data)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--players", type=int, choices=(2,4,8), default=2)
    parser.add_argument("--port", type=int, default=30600)
    parser.add_argument("--source-overlay", action="store_true")
    parser.add_argument("--save-match",action="store_true")
    parser.add_argument("--load-directory",type=Path)
    args = parser.parse_args()
    runtime = args.runtime.resolve(strict=True)
    folder = ROOT/"build/issue438"/datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    folder.mkdir(parents=True)
    package = folder/"checks.pk3"
    fixture(package,args.players,args.source_overlay,args.save_match)
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    processes, streams, commands = [], [], []
    try:
        for i in range(args.players):
            peer = folder/f"peer{i}"
            peer.mkdir()
            cfg = peer/"test.cfg"
            cfg.write_text(("wait 100; netevent ca_session_recover; netevent ca438_verify_reload; " if args.load_directory and i==0 else "")+f"wait {1800+(args.players-i)*35}; quit\n",encoding="utf-8")
            ini = peer/"isolated.ini"
            ini.write_text("[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=false\nlanguage=en\n",encoding="utf-8")
            network = ["-host",str(args.players),"-port",str(args.port),"-netmode","0"] if i==0 else ["-join",f"127.0.0.1:{args.port}","-port",str(args.port+i)]
            entry=["+map","MAP03"]
            if args.load_directory:
                saves=list((args.load_directory/f"peer{i}").glob("save*.zds"))
                if len(saves)!=1:raise RuntimeError(f"Expected one native save for peer {i}")
                (peer/"recovery.zds").write_bytes(saves[0].read_bytes())
                entry=["-loadgame","recovery.zds"]
            command = [str(ENGINE),"-noautoload","-iwad",str(IWAD),"-file",str(runtime),str(package),"-config",str(ini),"-savedir",str(peer),"-window","-width","640","-height","480","-rngseed","438",*network,"+logfile",str(peer/"engine.log"),*entry,"+exec",str(cfg)]
            commands.append(command)
            stream = (peer/"process.log").open("wb")
            streams.append(stream)
            processes.append(subprocess.Popen(command,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream))
            time.sleep(0.3)
        print(f"Started {args.players} native peers: {folder}",flush=True)
        deadline = time.monotonic()+100
        fatal = ("Execution could not continue", "VM execution aborted", "Script error", "errors while compiling", "Bad type", "Attempt to redefine", "Cannot find savegame", "Unknown type", "Unknown sprite")
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
            if any(any(t in p.read_text(encoding="utf-8",errors="replace") for t in fatal) for p in folder.glob("peer*/engine.log")):
                break
            time.sleep(0.2)
    finally:
        for p in processes:
            if p.poll() is None:
                p.terminate()
                p.wait(timeout=10)
        for stream in streams:
            stream.close()
    reports = []
    for i,process in enumerate(processes):
        path = folder/f"peer{i}/engine.log"
        log = path.read_text(encoding="utf-8",errors="replace") if path.exists() else ""
        errors = [s for s in log.splitlines() if any(t in s for t in (*fatal,"CA438 FAIL","desync","out of sync"))]
        checks = [s for s in log.splitlines() if s.startswith("CA438 ")]
        expected=13 if args.save_match else 26 if args.load_directory else 39
        passed = process.returncode==0 and not errors and log.count("CA438 PASS")==expected and log.count("CA438 RESULT")==1
        reports.append({"peer":i,"exit":process.returncode,"passed":passed,"checks":checks,"errors":errors})
    report = {"issue":438,"save_match":args.save_match,"load_directory":str(args.load_directory) if args.load_directory else None,"players":args.players,"source_overlay":args.source_overlay,"commands":commands,"peers":reports,"passed":all(x["passed"] for x in reports)}
    for label,path in (("runtime",runtime),("engine",ENGINE),("iwad",IWAD),("fixture",package)):
        report[label+"_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
    (folder/"results.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"directory":str(folder),"passed":report["passed"],"peers":[{"peer":r["peer"],"exit":r["exit"],"count":sum(" PASS " in c for c in r["checks"]),"errors":r["errors"]} for r in reports]},indent=2),flush=True)
    if not report["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
