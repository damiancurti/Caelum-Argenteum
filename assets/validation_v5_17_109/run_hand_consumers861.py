"""Exercise real ownership, Moon snapshots and the actual appearance preview."""
from pathlib import Path
import argparse,sys
ROOT=Path(__file__).resolve().parents[2];helper=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--sex',type=int,choices=[0,1],default=0)
opt,rest=p.parse_known_args();sys.argv=[sys.argv[0]]+rest
original=ROOT/'assets/validation_v5_17_107/run_wardrobe857.py';source=original.read_text(encoding='utf-8')
fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_continuity861.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_consumers861.zs').read_text(encoding='utf-8')
fixture=fixture.replace('SEX861',str(opt.sex)).replace('GLOVE861','CaelumClothingData.GP').replace('EXPECTED861','true').replace('DEATH_SNAPSHOT861','true')
source=source.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture)).replace('CA857WardrobeProbe','CA861ConsumerProbe').replace("'issue':857","'issue':861")
commands='con_notifytime 0; wait 100; netevent ca861seed; wait 35; netevent ca861consumers; wait 10; netevent ca861open; wait 20; netevent ca861inspect 1; screenshot preview-gloves.png; wait 5; netevent ca861bare; wait 20; netevent ca861inspect 0; screenshot preview-bare.png; wait 5; netevent ca861close; wait 10; netevent ca861done; wait 10; quit'
old='wait 100; netevent ca857check; wait 10; save reach.zds; wait 10; quit';assert source.count(old)==1;source=source.replace(old,commands)
source=source.replace("exec(compile(source,str(original),'exec')", "source=source.replace(\"command+=['+exec',str(commands)]\",\"command+=['-host','1','+exec',str(commands)]\")\nexec(compile(source,str(original),'exec')")
source=source.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Native drop/replacement/layering, direct stale-record guard, native Moon initialization snapshot and actual appearance preview. One-player cooperative mode keeps menus unpaused. Diagnostic setup only; no full Moon permission/resource or author acceptance claim.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
