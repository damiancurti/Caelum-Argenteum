"""Create a matched-purpose old/new southern encounter camera probe."""
from pathlib import Path
import argparse
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]

def build(destination):
    data=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    old=json.loads((ROOT/'assets/map02_maze/legacy_5161/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    points=[]
    for manifest in [old,data]:
        center=next(r['center'] for r in manifest['rooms'] if r['zone']==0)
        points.append([center[0]-128,center[1]-64,0])
    source='''class CA454Scene : EventHandler {
int Age; bool Placed;
void Place() {
 let user=CaelumPlayer(players[0].mo);if(user==null || Placed)return;
 let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();
 if(marker==null)return;
 vector3 point=marker.args[0]>=6?NEW_POINT:OLD_POINT;
 user.bInvulnerable=true;user.GetPersistentCharacterState(true).DemoNarrativeDelivered=2047;
 user.GetPersistentCharacterState(true).DemoNarrativePending=0;
 user.SetOrigin(point,false);user.FindFloorCeiling();user.SetOrigin((point.X,point.Y,user.FloorZ),false);
 user.Angle=0;user.Pitch=0;user.Vel=(0,0,0);Placed=true;
 Console.Printf("CA454 SCENE revision=%d point=(%.1f,%.1f,%.1f)",marker.args[0],user.Pos.X,user.Pos.Y,user.Pos.Z);
}
override void WorldTick() {
 Age++;if(Age==200)Place();
 if(Age!=350 && Age!=1050)return;
 int targeting=0;let it=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
 while((body=CaelumCombatActor(it.Next()))!=null)if(body.health>0 && body.Target==players[0].mo)targeting++;
 Console.Printf("CA454 SCENE active_targets=%d age=%d",targeting,Age);
}
override void NetworkProcess(ConsoleEvent e) {
 if(e.Name!="ca454_probe")return;Place();
 Console.Printf("CA454 NATIVE %s map=%s",Placed?"PASS":"FAIL",level.MapName);
}
}'''
    for name,point in zip(['OLD_POINT','NEW_POINT'],points):source=source.replace(name,'('+','.join(map(str,point))+')')
    destination.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(destination,'w') as archive:
        for name,content in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"',
            'MAPINFO':'gameinfo { AddEventHandlers="CA454Scene" }','probe.zs':source}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),content.encode())
    return points

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('destination',type=Path);args=parser.parse_args()
    print(json.dumps({'cameras':build(args.destination)}))
