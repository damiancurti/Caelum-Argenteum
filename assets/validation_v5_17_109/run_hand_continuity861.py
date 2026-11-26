"""Native save continuity and actual first-person glove inspection."""
from pathlib import Path
import argparse,sys
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__,epilog='Shared arguments: --runtime PATH --output NEW_BUILD_DIRECTORY [--load SAVE] [--candidate OVERLAY].')
parser.add_argument('--mode',choices=['seed','load','hub','death','dead-load','motion'],required=True)
parser.add_argument('--baseline',action='store_true')
parser.add_argument('--legacy-death',action='store_true',help='Expect a pre-109 corpse to retain its saved armor-only glove snapshot.')
parser.add_argument('--glove',choices=['bare','GF','GC','GW','GP'],default='GP')
parser.add_argument('--sex',choices=[0,1],type=int,default=0)
opt,rest=parser.parse_known_args();sys.argv=[sys.argv[0]]+rest
if opt.legacy_death and opt.mode!='dead-load':parser.error('--legacy-death requires --mode dead-load')
original=ROOT/'assets/validation_v5_17_107/run_wardrobe857.py';source=original.read_text(encoding='utf-8')
fixture=Path(__file__).with_name('hand_continuity861.zs').read_text(encoding='utf-8')
fixture=fixture.replace('SEX861',str(opt.sex)).replace('GLOVE861','-1' if opt.glove=='bare' else 'CaelumClothingData.'+opt.glove).replace('EXPECTED861','false' if opt.baseline else 'true')
fixture=fixture.replace('DEATH_SNAPSHOT861','false' if opt.baseline or opt.legacy_death else 'true')
if not opt.baseline:
    fixture=fixture.replace('// CACHE861','''Check(User.AppearanceHandLayerReady[0] && User.AppearanceHandLayerReady[1] && User.AppearanceHandStateReady,"transient selection caches reconstruct on demand");
        Check(User.AppearanceHandLayers[1]==item,"reconstructed cache references actual native owned object");''')
fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+fixture
source=source.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture))
source=source.replace('CA857WardrobeProbe','CA861HandProbe').replace("'issue':857","'issue':861")
source=source.replace("exec(compile(source,str(original),'exec')",'''source=source.replace("'maps/CA836A.wad':wad,","'maps/CA836A.wad':wad,'maps/CA861B.wad':wad,")
source=source.replace('map CA836A "Candidate reach checks" {}','cluster 98 { hub } map CA836A "Hand continuity" { cluster=98 } map CA861B "Hand hub" { cluster=98 }')
exec(compile(source,str(original),'exec')''')
start='con_notifytime 0; wait 100; '
done='netevent ca861done; wait 10; quit\n'
plans={
 'seed':start+'netevent ca861seed; wait 35; screenshot hands.png; save reach.zds; wait 10; '+done,
 'load':start+'netevent ca861loaded; wait 35; screenshot hands.png; save reach.zds; wait 10; '+done,
 'hub':start+'netevent ca861loaded; wait 3; changemap CA861B; wait 35; netevent ca861loaded; wait 3; changemap CA836A; wait 35; netevent ca861loaded; wait 3; save reach.zds; wait 10; '+done,
 'death':start+'netevent ca861seed; wait 35; netevent ca861kill; wait 70; netevent ca861dead; screenshot death.png; save reach.zds; wait 10; '+done,
 'dead-load':start+'netevent ca861dead; screenshot death-loaded.png; save reach.zds; wait 10; '+done,
 'motion':start+'netevent ca861seed; wait 35; netevent ca861pose 0; screenshot idle.png; +attack; wait 4; netevent ca861pose 1; screenshot attack.png; -attack; wait 80; +zoom; wait 2; -zoom; wait 12; netevent ca861pose 2; screenshot guard.png; +zoom; wait 2; -zoom; wait 35; netevent ca861pose 0; screenshot restored.png; netevent ca861loaded; '+done,
}
old="wait 100; netevent ca857check; wait 10; save reach.zds; wait 10; quit"
assert source.count(old)==1, 'Shared command-plan insertion point changed.'
source=source.replace(old,plans[opt.mode].rstrip('\n'))
if opt.mode in ('death','dead-load'):
    source=source.replace("exec(compile(source,str(original),'exec')", "source=source.replace(\"command+=['+exec',str(commands)]\",\"command+=['-host','1','+exec',str(commands)]\")\nexec(compile(source,str(original),'exec')")
source=source.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Actual native hand selection, save and visual fixture. Diagnostic setup supplies owned equipment and invulnerability; native resources/timing remain authoritative. Death uses native one-player cooperative mode. Not author acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
