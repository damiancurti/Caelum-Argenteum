from pathlib import Path
import argparse,sys
p=argparse.ArgumentParser(description='Exercise actual hand ownership on the ordinary or opt-in player.')
p.add_argument('--ordinary-player',action='store_true')
options,rest=p.parse_known_args();sys.argv=[sys.argv[0]]+rest
h=Path(__file__).resolve().parent
root=Path(__file__).resolve().parents[2]
original=root/'assets/validation_v5_17_107/run_wardrobe857.py'
s=original.read_text(encoding='utf-8');fixture=(h/'hand_ownership861.zs').read_text(encoding='utf-8')
s=s.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture))
s=s.replace("'issue':857", "'issue':861")
s=s.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Actual native clothing/armor hand selector candidate; native ownership, direct stale-object guards and42 profile choices; save/performance/visual acceptance remains separate.')
if options.ordinary_player:s=s.replace('CaelumDomingoPilotPlayer','CaelumPlayer').replace('existing opt-in native player','existing ordinary native player')
exec(compile(s,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
