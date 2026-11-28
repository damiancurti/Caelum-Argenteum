"""Fire the real death hook on all fourteen player profiles, reloading the same live baseline."""

import io
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import zipfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "validation_v5_18_13"))
from check_slam import stage_wad
from PIL import Image

CODE = """version "4.14.2"
class FallEye : Actor {Default {+NOGRAVITY +NOINTERACTION} States {Spawn:TNT1 A -1;Stop;}}
class LivePlayerFall : StaticEventHandler
{
    int id,previous; bool armed;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="fall_player")return;
        let body=CaelumPlayer(players[e.Player].mo);
        if(body==null || body.CharacterProfile==null || body.health<=0)return;
        id=e.Args[0];previous=-1;armed=true;
        let p=body.CharacterProfile;
        p.Race=id<2?CaelumConstants.RACE_HUMAN:id<4?CaelumConstants.RACE_CAELITH:id<6?CaelumConstants.RACE_GOBLIN:CaelumConstants.RACE_BEAST_MAN;
        p.Sex=id%2;p.BeastForm=id<6?0:(id-6)/2;p.Face=id%4;p.SkinTone=id%3;
        body.SetOrigin((0,0,0),false);body.Angle=270;body.UpdateWorldCarbineVisual();
        let eye=Actor.Spawn('FallEye',(56,-104,41),NO_REPLACE);eye.Angle=118;players[e.Player].Camera=eye;
        body.health=0;body.Die(null,null,0,'None');
    }
    override void WorldTick()
    {
        if(!armed)return;
        let p=CaelumPlayer(players[0].mo);
        if(p==null || p.AppearanceDeathProfile==null || p.health>0 || p.AppearancePose==previous)return;
        let look=p.AppearanceDeathProfile;
        previous=p.AppearancePose;
        Console.Printf("PLAYERFALL id=%d snapshot=%d pose=%d mesh=%d",id,CaelumAppearance.Identity(look.Race,look.Sex,look.BeastForm),previous,p.FamilyVisualKey);
    }
}"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out / "players.pk3", "w") as z:
        z.writestr("ZSCRIPT", CODE)
        z.writestr("maps/CAST.wad", stage_wad())
        z.writestr(
            "MAPINFO",
            'gameinfo { PlayerClasses = "CaelumPlayer" EventHandlers = "LivePlayerFall" } map CAST "Cast" { nointermission }',
        )
        image = Image.new("RGB", (32, 32), (109, 109, 109))
        stream = io.BytesIO()
        image.save(stream, "PNG")
        for t in ("FLAPISO", "FLATECH", "FLAPARED"):
            z.writestr("textures/" + t + ".png", stream.getvalue())
    for i in range(14):
        commands = [f"netevent fall_player {i}", "wait 50", f"screenshot player{i:02}.png", "wait 18"]
        commands += ["load baseline.zds", "wait 40", f"exec player{i + 1}.cfg"] if i < 13 else ["quit"]
        (out / f"player{i}.cfg").write_bytes(("; ".join(commands) + "\n").encode())
    (out / "run.cfg").write_text(
        "snd_mastervolume 0\ni_pauseinbackground false\nvid_activeinbackground true\nvid_lowerinbackground false\nscreenblocks 12\nwait 130; save baseline; wait 40; exec player0.cfg\n"
    )
    with (out / "console.log").open("wb") as f:
        subprocess.run(
            [
                os.environ.get("GZDOOM_EXE", r"C:\Program Files (x86)\GZDoom\gzdoom.exe"),
                "-nosound",
                "-noautoload",
                "-iwad",
                str(args.game.resolve()),
                "-file",
                str(out / "players.pk3"),
                "-config",
                str(out / "test.ini"),
                "-savedir",
                str(out),
                "-window",
                "+logfile",
                str(out / "engine.log"),
                "+map",
                "CAST",
                "+exec",
                str(out / "run.cfg"),
            ],
            cwd=out,
            stdout=f,
            stderr=f,
            check=True,
            timeout=210,
        )
    log = (out / "engine.log").read_text("utf8", errors="replace")
    poses = {}
    for i, snapshot, pose, mesh in re.findall(
        r"PLAYERFALL id=(\d+) snapshot=(\d+) pose=(\d+) mesh=(\d+)", log
    ):
        assert i == snapshot and int(mesh) > 0
        poses.setdefault(int(i), []).append(int(pose))
    for i in range(14):
        samples = poses.get(i, [])
        assert [p for p in samples if p in range(12, 16)] == [12, 13, 14, 15] and (
            out / f"player{i:02}.png"
        ).is_file(), (i, samples)
    (out / "result.json").write_bytes((json.dumps(poses, indent=2) + "\n").encode())


if __name__ == "__main__":
    main()
