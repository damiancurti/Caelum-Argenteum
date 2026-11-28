"""Open the stationary inspection room or verify it in the installed Windows engine."""
import argparse
import ctypes
from contextlib import contextmanager
import json
import os
from pathlib import Path
import re
import subprocess
import sys

@contextmanager
def keep_awake():
    """Temporarily prevent automatic sleep while this engine session is running."""
    if os.name!="nt":
        yield
        return
    set_state=ctypes.windll.kernel32.SetThreadExecutionState
    set_state.argtypes=[ctypes.c_uint]
    set_state.restype=ctypes.c_uint
    if not set_state(0x80000001):
        raise OSError("Windows could not register the temporary keep-awake request.")
    try:
        yield
    finally:
        set_state(0x80000000)


ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--game",type=Path)
parser.add_argument("--engine",type=Path)
parser.add_argument("--output",type=Path,default=ROOT/"build/model-gallery")
parser.add_argument("--check",action="store_true")
args = parser.parse_args()
out = args.output.resolve()
if args.game:
    game = args.game.resolve(strict=True)
else:
    release = re.search(r'Current release:\s*(\d+\.\d+\.\d+[a-z]?)',(ROOT/"README.md").read_text("utf8"))[1]
    folder = ROOT/"build"/f"CaelumArgenteum-{release}-prologue"
    game = folder/"caelum_argenteum.ipk3"
    if not game.is_file():
        subprocess.run([sys.executable,str(ROOT/"build_release.py"),"--output",str(folder)],check=True)
engine = args.engine or Path(os.environ.get("GZDOOM_EXE",r"C:\Program Files (x86)\GZDoom\gzdoom.exe"))
if not engine.is_file():
    parser.error("Pass --engine or set GZDOOM_EXE to the installed GZDoom 4.14.2 executable.")
subprocess.run([sys.executable,"-X","utf8",str(HERE/"build_gallery.py"),"--output",str(out)],check=True)
roster = json.loads((out/"roster.json").read_bytes())
by_label = {item["label"]:item["station"] for item in roster}
groups = {label:next(row["station"] for row in roster if row["group"]==label)
          for label in ("Jugadores","Nuevos modelos","Bestiario","Vestuario","Equipo")}
shortcuts = [groups["Jugadores"],groups["Nuevos modelos"],by_label["Toro"],groups["Bestiario"],groups["Vestuario"],groups["Equipo"]]
run = out/("prueba" if args.check else "visita")
run.mkdir(parents=True,exist_ok=True)
cfg = run/"controles.cfg"
binds = ["bind w +forward","bind s +back","bind a +moveleft","bind d +moveright",
         'bind pgup "netevent fila_anterior"','bind pgdn "netevent fila_siguiente"',
         "bind escape menu_main","freelook true","r_drawplayersprites false","vid_rendermode 4",
         "screenblocks 12","crosshair 0","show_messages false","vid_maxfps 60","cl_capfps false",
         "i_pauseinbackground false","vid_activeinbackground true","vid_lowerinbackground false","snd_mastervolume 0"]
binds.extend(f'bind {key} "netevent fila_puesto {slot}"' for key,slot in enumerate(shortcuts,1))
samples = dict(familia=1,mandinga=15,zupay=16,rata=17,domingo=18,domingo_original=19,toro=by_label["Toro"],
               pombero=by_label["Pombero"],cuero=next(row["station"] for row in roster if "Cuero /" in row["label"]),
               nahuelito=by_label["Nahuelito"],arma=groups["Equipo"],armadura=len(roster))
if args.check:
    # Visit each rendered station, retaining representative screenshots. Short
    # chained configs keep the engine console parser below its line limit.
    names_by_station={station:name for name,station in samples.items()}
    per_page=16
    for start in range(0,len(roster),per_page):
        commands=[]
        for station in range(start+1,min(start+per_page,len(roster))+1):
            commands.extend([f"netevent fila_puesto {station}","wait 4"])
            if station in names_by_station:
                commands.extend([f"screenshot {names_by_station[station]}.png","wait 3"])
        if start+per_page<len(roster):
            commands.append(f"exec walk{start+per_page}.cfg")
        else:
            commands.extend(["netevent fila_anterior","wait 5","netevent fila_siguiente","wait 5","quit"])
        (run/f"walk{start}.cfg").write_bytes(("; ".join(commands)+"\n").encode())
    binds.append("wait 140; exec walk0.cfg")
cfg.write_bytes(("\n".join(binds)+"\n").encode())
print("Galería 3D de Caelum Argenteum\nWASD para caminar. Ratón para mirar. RePág y AvPág para cambiar de puesto.\n"
      "1 Jugadores   2 Mandinga, Zupay y rata   3 Toro   4 Bestiario   5 Vestuario   6 Equipo",flush=True)
log = run/"motor.log"
with keep_awake(), (run/"proceso.log").open("wb") as output:
    proc = subprocess.run([str(engine),"-nosound", "-noautoload","-iwad",str(game),"-file",str(out/"galeria.pk3"),
                           "-config",str(run/"gzdoom.ini"),"-savedir",str(run),"-window","+logfile",str(log),
                           "+map","GALERIA","+exec",str(cfg),"+language","es"],
                          cwd=run,stdout=output,stderr=output,timeout=160 if args.check else None)
if proc.returncode:
    raise SystemExit(f"GZDoom exited with {proc.returncode}. {log}")
if args.check:
    text=log.read_text("utf8",errors="replace")
    rows=re.findall(r"GALERIA t=(\d+) inmoviles=(\d+) total=(\d+)",text)
    if rows!=[(str(t),str(len(roster)),str(len(roster))) for t in (4,109)]:
        raise SystemExit(f"Unexpected exhibit census {rows}. {log}")
    visits=[int(value) for value in re.findall(r"GALERIA puesto=(\d+)",text)]
    expected=[1,*range(1,len(roster)+1),len(roster)-1,len(roster)]
    if visits!=expected:
        raise SystemExit(f"Unexpected station navigation {visits}.")
    for name in samples:
        if f"Captured {name}.png" not in text or not (run/(name+".png")).is_file():
            raise SystemExit(f"Missing capture for {name}.")
    print(f"GZDoom verified {len(roster)} stationary exhibits and visited each station. Captured {len(samples)} representative views.")

