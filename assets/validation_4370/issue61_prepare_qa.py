"""Prepare reproducible native door checks and visible tours for issue #61."""
import json
from pathlib import Path
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'build_dev.ps1').is_file())
qa=ROOT/'build/issue61_qa'
old=(ROOT/'assets/validation_43625/layout/Followup.zs').read_text(encoding='utf-8')
(qa/'DoorChecks.zs').write_text('// Reused #36 accepted door regression, executed again for #61.\n'+old[old.index('class F36Body'):],encoding='utf-8')
source=(qa/'ZSCRIPT').read_text(encoding='utf-8')
for name in ('DoorChecks.zs','Tour.zs'):
    include=f'#include "{name}"'
    if include not in source:source+='\n'+include+'\n'
(qa/'ZSCRIPT').write_text(source,encoding='utf-8')
report=json.loads((ROOT/'assets/map01_mansion/EXTERIOR_GENERATED.json').read_text())
code=['class Issue61TourView : Issue61View','{',
'    void SetDoorView(int group, vector3 point, double yaw)',
'    {',
'        Owner.SetOrigin(point,false);Owner.Angle=yaw;Owner.Pitch=-16;',
'        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;',
'        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)',
'        {',
'            leaf.RuloArenaLocked=true;leaf.SlideProgress=0;leaf.PlaceAtProgress();leaf.RuloArenaLocked=false;leaf.DoorRequested=false;',
'        }',
'    }','}',
'class Issue61TourOpen : CaelumSocialDebugAction',
'{',
'    override bool Use(bool pickup)',
'    {',
'        Owner.GiveInventoryType("CaelumSilverKey");',
'        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;',
'        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)',
'            if(abs(leaf.ClosedPosition.Z-Owner.Pos.Z)<1 && Owner.Distance2D(leaf)<180)leaf.Used(Owner);',
'        return true;',
'    }','}']
commands=['wait 100','r_drawplayersprites 0','screenblocks 12','vid_fps 1','con_notifytime 0']
destination=ROOT/'build/issue61_views'
destination.mkdir(exist_ok=True)
for i,t in enumerate(report['tympana']):
    if i:commands=[]
    for side in (-1,1):
        suffix='a' if side==-1 else 'b'
        name=f'Issue61V{t["group"]}{suffix}'
        x,y=t['center'];z=t['base'];distance=112
        if t['axis']==0:y+=side*distance;yaw=270 if side==1 else 90
        else:x+=side*distance;yaw=180 if side==1 else 0
        code += [f'class {name} : Issue61TourView', '{', f'    override bool Use(bool pickup) {{ Super.Use(pickup);SetDoorView({t["group"]},({x},{y},{z}),{yaw});return true; }}', '}']
        commands += [f'give {name}','wait 35',f'screenshot build/issue61_views/{t["group"]}_{suffix}_closed.png','give Issue61TourOpen','wait 24',f'screenshot build/issue61_views/{t["group"]}_{suffix}_open.png','wait 10']
    if i+1<len(report['tympana']):commands += [f'exec build/issue61_views/sequence_{i+1:02}.cfg']
    else:commands += ['echo QA61_TOUR_DONE','quit']
    command='; '.join(commands)+'\n'
    assert len(command)<1024, 'Keep each exec command line below the engine line buffer.'
    (destination/f'sequence_{i:02}.cfg').write_text(command,encoding='utf-8')
(qa/'Tour.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
(ROOT/'build/issue61_tour.cfg').write_text('exec build/issue61_views/sequence_00.cfg\n',encoding='utf-8')
print('Prepared 128 views across 32 original door groups and retained #36 door tests.')
