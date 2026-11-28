"""Play the real Zupay melee state and record wind-up, impact and recovery on a closed stage."""

import argparse, json, re, struct, subprocess, sys, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path(r"C:\Program Files (x86)\GZDoom\gzdoom.exe")
CODE = """version "4.14.2"
class MotionVisitor : DoomPlayer { override void GiveDefaultInventory() {} }
class SlamTarget : Actor { Default { Radius 14; Height 56; Health 100; +SHOOTABLE +INVULNERABLE +NOGRAVITY +NOBLOCKMAP } States {Spawn:TNT1 A -1;Stop;} }
class SlamInspection : StaticEventHandler {
    CaelumZupayColossus boss;
    Actor mark;
    int started;
    override void WorldTick() {
        if(level.MapName!="MOTION" || !players[0].mo)return;
        let visitor=players[0].mo;
        if(level.time==4){
            boss=CaelumZupayColossus(Actor.Spawn("CaelumZupayColossus",(0,0,0),NO_REPLACE));
            boss.Angle=270;
            mark=Actor.Spawn("SlamTarget",(0,-35,0),NO_REPLACE);
            visitor.bInvulnerable=true;visitor.bShootable=false;
            visitor.SetOrigin((78,-158,0),false);visitor.Angle=116;visitor.Pitch=0;
            visitor.ViewHeight=46;visitor.player.ViewHeight=46;
        }
        if(!boss || level.time<12)return;
        if((level.time-12)%116==0) {
            boss.Angle=270;boss.Vel=(0,0,0);boss.SetOrigin((0,0,0),false);
            mark.SetOrigin((0,-35,0),false);mark.Vel=(0,0,0);
            boss.Target=mark;boss.CurrentCombatAir=boss.MaximumCombatAir;
            CaelumVisualPerception.Evidence(boss).GetMemory().Remember(mark,mark.Pos,level.time,boss);
            boss.SetState(boss.FindState("AbsentMeleePrepare"));started=level.time;
        }
        if(level.time-started>=0 && level.time-started<=80)
            Console.Printf("SLAM t=%d pose=%d active=%d prepare=%d recover=%d",level.time-started,boss.Frame,
                boss.Sprite==boss.FindState("SlamArt").Sprite,boss.CurState==boss.FindState("AbsentMeleePrepare"),
                boss.CurState==boss.FindState("AbsentMeleeRecovery"));
    }
}"""


def stage_wad():
    geometry = ['namespace="ZDoom";']
    for x, y in [(-310, -310), (-310, 240), (310, 240), (310, -310)]:
        geometry.append(f"vertex {{x={x};y={y};}}")
    geometry.append(
        'sector {heightfloor=0;heightceiling=280;texturefloor="FLAPISO";textureceiling="FLATECH";lightlevel=224;}'
    )
    for i in range(4):
        geometry += [
            'sidedef {sector=0;texturemiddle="FLAPARED";}',
            f"linedef {{v1={i};v2={(i + 1) % 4};sidefront={i};blocking=true;}}",
        ]
    geometry.append(
        "thing {x=78;y=-158;angle=116;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;}"
    )
    data = bytearray(12)
    directory = bytearray()
    for name, blob in [("MOTION", b""), ("TEXTMAP", "\n".join(geometry).encode()), ("ENDMAP", b"")]:
        directory.extend(struct.pack("<ii8s", len(data), len(blob), name.encode()))
        data.extend(blob)
    struct.pack_into("<4sii", data, 0, b"PWAD", 3, len(data))
    return data + directory


def overlay(out):
    target = out / "review.pk3"
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as z:
        with zipfile.ZipFile(out / "galeria.pk3") as gallery:
            for name in gallery.namelist():
                if name.startswith("textures/"):
                    z.writestr(name, gallery.read(name))
        z.writestr("maps/MOTION.wad", stage_wad())
        z.writestr("ZSCRIPT", CODE)
        z.writestr(
            "MAPINFO",
            'gameinfo { PlayerClasses = "MotionVisitor" EventHandlers = "SlamInspection" StatusBarClass = "BaseStatusBar" }\nmap MOTION "Zupay" { nointermission }',
        )
    return target


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--game", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--engine", type=Path, default=ENGINE)
    p.add_argument("--overlay", type=Path)
    p.add_argument("--interactive", action="store_true")
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [sys.executable, str(ROOT / "assets/validation_v5_18_10/build_gallery.py"), "--output", str(out)],
        check=True,
    )
    QA = overlay(out)
    cfg = [
        "i_pauseinbackground false",
        "vid_activeinbackground true",
        "vid_lowerinbackground false",
        "snd_mastervolume 0",
        "screenblocks 12",
        "r_drawplayersprites false",
        "crosshair 0",
        "show_messages false",
    ]
    if not args.interactive:
        # A second cycle gives the renderer time to finish its first upload.
        capture = ["wait 129"]
        for i in range(40):
            capture.extend([f"screenshot slam{i:02}.png", "wait 2"])
        capture.append("quit")
        cfg.append("; ".join(capture))
    (out / "view.cfg").write_text("\n".join(cfg) + "\n")
    with (out / "console.log").open("wb") as f:
        subprocess.run(
            [
                str(args.engine),
                "-nosound",
                "-noautoload",
                "-iwad",
                str(args.game.resolve()),
                "-file",
                *([str(args.overlay.resolve())] if args.overlay else []),
                str(QA),
                "-config",
                str(out / "engine.ini"),
                "-window",
                "+logfile",
                str(out / "engine.log"),
                "+map",
                "MOTION",
                "+exec",
                str(out / "view.cfg"),
            ],
            cwd=out,
            stdout=f,
            stderr=f,
            check=True,
            timeout=None if args.interactive else 80,
        )
    if args.interactive:
        return
    log = (out / "engine.log").read_text("utf8", errors="replace")
    samples = re.findall(r"^SLAM t=(\d+) pose=(\d+) active=(\d) prepare=(\d) recover=(\d)", log, re.M)
    seen = {int(i) for _, i, on, _, _ in samples if on == "1"}
    assert seen == set(range(25)) and all((out / f"slam{i:02}.png").exists() for i in range(40)), (
        seen,
        log[-350:],
    )
    assert any(on == "1" and rec == "1" and idx == "16" for _, idx, on, _, rec in samples)
    assert not any(
        e in log for e in ("Script error", "VM execution aborted", "Execution could not continue")
    )
    (out / "result.json").write_text(
        json.dumps({"poses": len(seen), "captures": 40, "state_samples": samples}, indent=2)
    )


if __name__ == "__main__":
    main()
