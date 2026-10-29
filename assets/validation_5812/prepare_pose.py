"""Extend the retained toilet fixture without changing its original addon."""
from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
source=(here/'checks.zs').read_text(encoding='utf-8')
source=source.replace('    override void NetworkProcess(ConsoleEvent e)',(here/'pose_checks.zs').read_text(encoding='utf-8')+'\n    override void NetworkProcess(ConsoleEvent e)')
source=source.replace("        if(e.Name=='ca502h_core')Core(u);", """        if(e.Name=='ca502h_pose')PoseCore(u);
        else if(e.Name=='ca502h_pose_seed')PoseSeed(u);
        else if(e.Name=='ca502h_pose_load')PoseLoad(u);
        else if(e.Name=='ca502h_pose_legacy')PoseLegacy(u);
        else if(e.Name=='ca502h_pose_hub')PoseHub(u);
        else if(e.Name=='ca502h_pose_toilet')PoseManual(u,false);
        else if(e.Name=='ca502h_pose_tub')PoseManual(u,true);
        else if(e.Name=='ca502h_core')Core(u);""")
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':source.encode(),'MAPINFO':b'GameInfo { AddEventHandlers="CA502HChecks" }\n'}
with zipfile.ZipFile(out/'pose-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={'pose-core':'wait 70; netevent ca502h_pose; wait 5; quit',
 'pose-save':'wait 70; netevent ca502h_pose_seed; save ca502h-pose; wait 5; quit',
 'pose-load':'wait 1; netevent ca502h_pose_load; wait 5; quit',
 'pose-legacy':'wait 1; netevent ca502h_pose_legacy; wait 5; quit',
 'pose-old-save':'wait 70; netevent ca502h_seed; save ca502h-prepose; wait 5; quit',
 'pose-hub':'wait 1; changemap CAH001; wait 70; netevent ca502h_pose_hub; changemap CAH000; wait 70; netevent ca502h_pose_hub; wait 5; quit',
 'pose-manual':'wait 70; netevent ca502h_pose_toilet; bind F1 "netevent ca502h_pose_toilet"; bind F2 "netevent ca502h_pose_tub"; bind F6 toggleconsole',
 'pose-capture':'wait 70; netevent ca502h_pose_toilet; +use; wait 1; -use; wait 15; screenshot pose-toilet.png; netevent ca502h_pose_tub; +use; wait 1; -use; wait 15; screenshot pose-tub.png; wait 5; quit'}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared posture addon and scripts; original hygiene addon preserved.')
