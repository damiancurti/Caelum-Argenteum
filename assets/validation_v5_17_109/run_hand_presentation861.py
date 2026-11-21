"""Measure matched native first-person views with actual clothing gloves.

Uses the retained Vulkan presentation and 700-tic reference-window runner.
Pass --baseline-fixture with the pre-109 runtime; keep all other inputs equal.
"""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2];helper=Path(__file__).resolve().parent
original=ROOT/'assets/validation_v5_17_107/run_wardrobe_continuity857.py';source=original.read_text(encoding='utf-8')
start=source.index('equipment=(helper/');end=source.index("on='set ca_wardrobe_candidate",start)
fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_continuity861.zs').read_text(encoding='utf-8')+'\n'+(helper/'hand_presentation861.zs').read_text(encoding='utf-8')
fixture=fixture.replace('SEX861','0').replace('GLOVE861','CaelumClothingData.GP').replace('DEATH_SNAPSHOT861','true')
source=source[:start]+'fixture='+repr(fixture)+"\nfixture=fixture.replace('EXPECTED861','false' if opt.baseline_fixture else 'true')\n"+source[end:]
source=source.replace('CA857WardrobeProbe','CA861PresentationProbe').replace('CA857 ','CA861 ').replace("'issue':857","'issue':861")
plan='con_notifytime 0; wait 100; netevent ca861seed; wait 175; netevent ca861loaded; netevent ca861benchstart; wait 700; netevent ca861benchend; screenshot scene.png; netevent ca861done; wait 35; quit\n'
source=source.replace("original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py'", "plans['bench']="+repr(plan)+"\noriginal=ROOT/'assets/validation_v5_17_96/run_reach_edges.py'")
source=source.replace('Native wardrobe continuity phase ','Matched first-person hand presentation phase ')
sys.argv+=['--mode','bench']
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
