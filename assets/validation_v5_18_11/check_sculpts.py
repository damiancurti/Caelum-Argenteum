"""Record original-scale front, profile and rear views of the sculpted models in GZDoom."""

import argparse
from pathlib import Path
import re
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--game", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--players", action="store_true")
parser.add_argument(
    "--hair", action="store_true", help="Inspect four hairstyles on the widest head for each humanoid."
)
parser.add_argument("--development-assets", action="store_true")
parser.add_argument(
    "--demon-actions",
    action="store_true",
    help="Inspect the bound clothing on walking, attacking and fallen figures.",
)
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
subprocess.run(
    [sys.executable, str(ROOT / "assets/validation_v5_18_10/build_gallery.py"), "--output", str(out)],
    check=True,
)
source = """version "4.14.2"
class SculptCamera : StaticEventHandler {
    override void NetworkProcess(ConsoleEvent e) {
        if(e.Name!="sculpt_view" && e.Name!="sculpt_hair" && e.Name!="sculpt_action")return;
        int id=e.Args[0];double angle=e.Args[1]-90.0;bool close=e.Args[2]>0;
        let it=ActorIterator.Create(999+id);
        let model=GalleryExhibit(it.Next());let eye=GalleryVisitor(players[e.Player].mo);
        if(!model || !eye)return;
        if(e.Name=="sculpt_hair"){
            int identity=id-1;
            String face=String.Format("head%d_2",identity);
            String hair=String.Format("hair%d_%d",identity,e.Args[2]);
            model.A_ChangeModel('None',5,"models/caelum/players",Name(face..".md3"),5,
                                "models/caelum/players",Name(face.."_0.png"),0);
            model.A_ChangeModel('None',6,"models/caelum/players",Name(hair..".md3"),6,
                                "models/caelum/players",Name(hair.."_1.png"),0);
            bool above=e.Args[1]>90;
            double offset=model.CameraDistance*(above?.33:.46);
            double height=model.EyeHeight*(above?2.65:1.85);
            eye.SetOrigin(model.Pos+(cos(angle)*offset,sin(angle)*offset,0),false);
            eye.Vel=(0,0,0);eye.Angle=angle+180;eye.Pitch=above?42:4;
            eye.ViewHeight=height;eye.player.ViewHeight=height;
            Console.Printf("SCULPT id=%d angle=%d style=%d",id,e.Args[1],e.Args[2]);return;
        }
        if(e.Name=="sculpt_action"){
            static const String mandinga[]={"miida","miwka","mirnb","mndgd","mndge","mndgl"};
            static const String zupay[]={"zuida","zuwka","zurna","zupyd","zupyr","zupyl"};
            int pose=clamp(e.Args[2],0,5);
            String stem=id==15?mandinga[pose]:zupay[pose];
            String folder=id==15?"models/caelum/creatures/mandinga":"models/caelum/creatures/zupay";
            model.A_ChangeModel('None',0,folder,Name(stem..".md3"),0,folder,Name(stem..".png"),0);
            close=false;
        }
        double distance=Max(12,model.CameraDistance*(close?.52:1.0));
        Vector3 target=model.Pos;
        if(id==17){target.Y-=close?10:1;distance=close?24:43;}
        eye.SetOrigin(target+(cos(angle)*distance,sin(angle)*distance,0),false);
        eye.Vel=(0,0,0);eye.Angle=angle+180;eye.Pitch=0;
        eye.ViewHeight=Clamp(model.EyeHeight*(close && id!=17?1.64:1.0),4,210);
        eye.player.ViewHeight=eye.ViewHeight;
        Console.Printf("SCULPT id=%d angle=%d close=%d",id,e.Args[1],close);
    }
}"""
qa = out / "camera.pk3"
with zipfile.ZipFile(qa, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("ZSCRIPT", source)
    z.writestr("MAPINFO", 'gameinfo { AddEventHandlers = "SculptCamera" }\n')
    if args.development_assets:
        for folder in ("creatures", "players") if args.players or args.hair else ("creatures",):
            for p in (ROOT / "src/models/caelum" / folder).glob("**/*" if folder == "creatures" else "*"):
                if p.is_file():
                    z.write(p, p.relative_to(ROOT / "src").as_posix())
stations = [*range(1, 15), 24, 25, 29, 147, 205] if args.players else [15, 16, 17, 24, 25]
if args.hair:
    stations = list(range(1, 7))
if args.demon_actions:
    stations = [15, 16]
controls = [
    "screenblocks 12",
    "r_drawplayersprites false",
    "show_messages false",
    "crosshair 0",
    "i_pauseinbackground false",
    "vid_activeinbackground true",
    "vid_lowerinbackground false",
    "snd_mastervolume 0",
    "wait 135; exec sample0.cfg",
]
(out / "check.cfg").write_text("\n".join(controls) + "\n")
expected = []
for k, station in enumerate(stations):
    commands = []
    views = (
        [(angle, style) for style in range(4) for angle in (32, 146)]
        if args.hair
        else [(angle, i) for i in range(6) for angle in (20, 132)]
        if args.demon_actions
        else [(0, 0), (65, 0), (165, 0), (22, 1)]
    )
    event = "sculpt_hair" if args.hair else "sculpt_action" if args.demon_actions else "sculpt_view"
    for angle, close in views:
        name = f"s{station:03}-{angle:03}-{close}"
        expected.append(name)
        commands.extend(
            [
                f"netevent {event} {station} {angle} {close}",
                "wait 6",
                f"screenshot {name}.png",
                "wait 2",
            ]
        )
    commands.append("quit" if k == len(stations) - 1 else f"exec sample{k + 1}.cfg")
    (out / f"sample{k}.cfg").write_text("; ".join(commands) + "\n")
with (out / "console.log").open("wb") as console:
    result = subprocess.run(
        [
            r"C:\Program Files (x86)\GZDoom\gzdoom.exe",
            "-nosound", "-noautoload",
            "-iwad",
            str(args.game.resolve()),
            "-file",
            str(out / "galeria.pk3"),
            str(qa),
            "-config",
            str(out / "review.ini"),
            "-window",
            "+logfile",
            str(out / "motor.log"),
            "+map",
            "GALERIA",
            "+exec",
            str(out / "check.cfg"),
        ],
        cwd=out,
        stdout=console,
        stderr=console,
        timeout=180,
    )
text = (out / "motor.log").read_text("utf8", errors="replace")
if result.returncode or any(
    s in text for s in ("Script error", "VM execution aborted", "Execution could not continue")
):
    raise RuntimeError(text[-2000:])
if len(re.findall(r"^SCULPT id=", text, re.M)) != len(expected) or any(
    f"Captured {n}.png" not in text for n in expected
):
    raise RuntimeError("Incomplete camera sequence")
print(f"Recorded {len(expected)} views in GZDoom 4.14.2")
