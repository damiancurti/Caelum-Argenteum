"""Exercise the real player binding for all family/sex identities with a cross-section of customization."""

from pathlib import Path
import argparse
import json
import re
import subprocess
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--game", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--engine", type=Path, default=Path(r"C:\Program Files (x86)\GZDoom\gzdoom.exe"))
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
game = args.game.resolve(strict=True)
with zipfile.ZipFile(out / "qa.pk3", "w") as package:
    package.writestr(
        "ZSCRIPT",
        """version "4.14.2"
class CA903Eye : Actor {Default { +NOGRAVITY +NOINTERACTION }}
class CA903Test : StaticEventHandler {
    override void WorldTick(){
        let player=CaelumPlayer(players[0].mo);
        if(player==null || player.CharacterProfile==null)return;
        if(level.time==3){
            let eye=Actor.Spawn("CA903Eye",player.Pos+(0,-120,44),NO_REPLACE);
            eye.Angle=90;players[0].Camera=eye;
        }
        if(level.time>10 && level.time<=24){
            int id=level.time-11;
            let p=player.CharacterProfile;
            p.Race=id<2?CaelumConstants.RACE_HUMAN:id<4?CaelumConstants.RACE_CAELITH:id<6?CaelumConstants.RACE_GOBLIN:CaelumConstants.RACE_BEAST_MAN;
            p.Sex=id%2;p.BeastForm=id<6?0:(id-6)/2;p.SkinTone=id%3;p.Face=id%4;
            p.HairStyle=(id+1)%4;p.HairColor=id%6;
            player.Angle=270;player.UpdateWorldCarbineVisual();
            Console.Printf("CA903 id=%d resolved=%d key=%d",id,CaelumAppearance.Identity(p.Race,p.Sex,p.BeastForm),player.FamilyVisualKey);
        }
        if(level.time%35==0) Console.Printf("CA903 current=%d key=%d",CaelumAppearance.Identity(player.CharacterProfile.Race,player.CharacterProfile.Sex,player.CharacterProfile.BeastForm),player.FamilyVisualKey);
    }
}
""",
    )
    package.writestr("MAPINFO", 'gameinfo { PlayerClasses = "CaelumPlayer" EventHandlers = "CA903Test" }\n')
cfg = out / "test.cfg"
cfg.write_text(
    "i_pauseinbackground false\nvid_activeinbackground true\nvid_lowerinbackground false\nsnd_mastervolume 0.05\nwait 145; quit\n"
)
log = out / "motor.log"
with (out / "process.log").open("wb") as f:
    subprocess.run(
        [
            str(args.engine),
            "-noautoload",
            "-iwad",
            str(game),
            "-file",
            str(out / "qa.pk3"),
            "-config",
            str(out / "settings.ini"),
            "-window",
            "+logfile",
            str(log),
            "+map",
            "MAP01",
            "+exec",
            str(cfg),
        ],
        cwd=out,
        stdout=f,
        stderr=f,
        check=True,
        timeout=145,
    )
text = log.read_text("utf8", errors="replace")
rows = [tuple(map(int, t)) for t in re.findall(r"^CA903 id=(\d+) resolved=(\d+) key=(\d+)", text, re.M)]
assert (
    [t[0] for t in rows] == list(range(14))
    and all(a == b and key > 0 for a, b, key in rows)
    and len({r[2] for r in rows}) == 14
), rows
assert not any(m in text for m in ("Execution could not continue", "VM execution aborted", "Script error"))
(out / "result.json").write_text(json.dumps(rows))
