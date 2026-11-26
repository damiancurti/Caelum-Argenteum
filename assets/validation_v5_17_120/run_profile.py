"""Measure an existing house or civic interior with the shared native observer.

The house uses the retained diagnostic city and actual portal/render ACK travel;
it is not a normal campaign population benchmark. Civic runs retain normal AI.
"""
from pathlib import Path
import json, sys

ROOT=Path(__file__).resolve().parents[2]
index=sys.argv.index('--scene');scene=sys.argv[index+1];del sys.argv[index:index+2]
assert scene in ('house','civic')
mapname='CAH000' if scene=='house' else 'MAP03'
name='house_living' if scene=='house' else 'municipality_inside'
inventory=json.loads((ROOT/'assets/source/art/environment_review_881/INVENTORY.json').read_text())
row=next(r for r in inventory['cameras'][mapname] if r['name']==name)
previous=ROOT/'assets/validation_v5_12_7/run_campaign_profile.py'
source=previous.read_text(encoding='utf-8')
anchor="    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')\n"
marker='user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);'
point=f'''user.SetOrigin(({row['point'][0]},{row['point'][1]},0),false);
            user.FindFloorCeiling();user.SetOrigin((user.Pos.X,user.Pos.Y,user.FloorZ),false);
            user.Angle={row['angle']};
            if(!user.TestMobjLocation() || user.CeilingZ-user.FloorZ<user.Height)
                Console.Printf("CA883 PROFILE FAIL clearance");
            '''
injected=anchor+f'    assert source.count({marker!r})==1\n    source=source.replace({marker!r},{(point+marker)!r})\n'
if scene=='house':
    age='Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;'
    injected+=f'    assert source.count({age!r})==1\n    source=source.replace({age!r},{("if(level.MapName!=\"CAH000\")return;"+age)!r})\n'
changes=[(anchor,injected),("'build/issue435'","'build/v516'"),
         ('campaign-profile-%Y','ceiling-profile-%Y'),('issue=435,','issue=883,'),
         ('map=args.map,siege=',f'map={mapname!r},scene={scene!r},siege='),
         ("'out of sync','desync'","'out of sync','desync','CA883 PROFILE FAIL','CA454 HOUSE FAIL','CA454 HOUSE USE FAIL'"),
         ('event ca510_frames; wait 3; quit','event ca510_frames; screenshot scene.png; wait 3; quit')]
if scene=='house':
    changes.append(("f'wait {duration}; event", "f'wait 140; netevent ca454_house_in 0; wait 140; wait {duration}; event"))
    add='''        members['house.zs']=(ROOT/'assets/validation_v5_16_2/barracas_house_use_probe.zs').read_bytes()
        members['ZSCRIPT']+=b'#include "house.zs"\\n'
        members['MAPINFO']=b'gameinfo { AddEventHandlers="CA510Performance","CA454HouseUseProbe" }\\ndoomednums {31050=CA454HouseUseCity}\\n'
'''
    changes.append(('        import native_sync\n',add+'        import native_sync\n'))
for old,new in changes:
    assert source.count(old)==1,old
    source=source.replace(old,new,1)
sys.path.insert(0,str(previous.parent))
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
