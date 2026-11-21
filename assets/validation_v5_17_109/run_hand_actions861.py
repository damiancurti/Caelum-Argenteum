"""Capture actual carbine reload and staff charge through native reload inputs."""
from pathlib import Path
import argparse,sys
ROOT=Path(__file__).resolve().parents[2];helper=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--sex',type=int,choices=[0,1],default=0);p.add_argument('--glove',choices=['bare','GP'],default='GP')
opt,rest=p.parse_known_args();sys.argv=[sys.argv[0]]+rest
original=ROOT/'assets/validation_v5_17_107/run_wardrobe857.py';source=original.read_text(encoding='utf-8')
fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_continuity861.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_actions861.zs').read_text(encoding='utf-8')
fixture=fixture.replace('SEX861',str(opt.sex)).replace('GLOVE861','-1' if opt.glove=='bare' else 'CaelumClothingData.GP').replace('EXPECTED861','true').replace('DEATH_SNAPSHOT861','true')
source=source.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture)).replace('CA857WardrobeProbe','CA861ActionsProbe').replace("'issue':857","'issue':861")
commands='con_notifytime 0; wait 100; netevent ca861seed; wait 35; netevent ca861equipaction 5; wait 100; netevent ca861action 0; screenshot carbine-ready.png; +reload; wait 3; -reload; wait 5; netevent ca861action 1; screenshot carbine-reload.png; wait 350; netevent ca861action 2; screenshot carbine-loaded.png; netevent ca861equipaction 0; wait 100; netevent ca861action 0; screenshot staff-ready.png; +reload; wait 3; -reload; wait 5; netevent ca861action 1; screenshot staff-charge.png; wait 350; netevent ca861action 2; screenshot staff-restored.png; netevent ca861loaded; wait 5; netevent ca861done; wait 10; quit'
old='wait 100; netevent ca857check; wait 10; save reach.zds; wait 10; quit';assert source.count(old)==1;source=source.replace(old,commands)
source=source.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Actual native reload input, carbine reload and staff charge clocks and hand layers. Setup supplies one canonical ammunition capacity and an empty magazine; it never pins resources or edits active clocks. Not author acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
