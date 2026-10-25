"""Build a separate bath fixture; preserve accepted toilet/posture addons."""
from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
proof='''class CA502BathProof : Inventory {
double Credit,Soap,C,Remaining,Removed,Water,Stamp;
Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
States {Spawn:TNT1 A -1;Stop;}}
'''
source=(here/'checks.zs').read_text(encoding='utf-8')
source=proof+source.replace('    override void NetworkProcess(ConsoleEvent e)',(here/'pose_checks.zs').read_text(encoding='utf-8')+'\n'+(here/'bath_checks.zs').read_text(encoding='utf-8')+'\n    override void NetworkProcess(ConsoleEvent e)')
source=source.replace("        if(e.Name=='ca502h_core')Core(u);", """        if(e.Name=='ca502h_bath')BathCore(u);
        else if(e.Name=='ca502h_bath_seed')BathSeed(u);
        else if(e.Name=='ca502h_bath_load')BathLoad(u);
        else if(e.Name=='ca502h_bath_hub')BathLoad(u,true);
        else if(e.Name=='ca502h_bath_live_begin')BathLiveBegin(u);
        else if(e.Name=='ca502h_bath_live_end')BathLiveEnd(u);
        else if(e.Name=='ca502h_bath_water_seed')BathWaterSeed(u);
        else if(e.Name=='ca502h_bath_water')BathWater(u);
        else if(e.Name=='ca502h_bath_legacy'){Check(CaelumSoapSupply.Find(u)==null && CaelumSoapSupply.Credit(u)==0,"pre-bath save starts with no fractional soap");Check(!CaelumBathTask.Active(u) && CaelumBathTask.Find(u)==null,"pre-bath save starts with no bath");Check(CaelumHygienePose.Active(u) && CaelumHygienePose.Find(u).Lying && CaelumFoodIllness.Value(u)>0,"old reclining posture and existing contamination remain valid");}
        else if(e.Name=='ca502h_bath_manual')BathManual(u);
        else if(e.Name=='ca502h_pose')PoseCore(u);
        else if(e.Name=='ca502h_pose_load')PoseLoad(u);
        else if(e.Name=='ca502h_pose_legacy')PoseLegacy(u);
        else if(e.Name=='ca502h_bath_status'){let bath=CaelumBathTask.Find(u);Console.Printf("CA502H STATUS C=%.3f water=%.3fL soap=%.6fg remainder=%.6fg remaining=%.3fs",CaelumFoodIllness.Value(u),CaelumDomesticWater.Get(CaelumHouseHubData.HouseForMap(level.MapName)).Liters,CaelumSoapSupply.Available(u),CaelumSoapSupply.Credit(u),u.CraftingTaskRemainingSeconds);}
        else if(e.Name=='ca502h_core')Core(u);""")
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':source.encode(),'MAPINFO':b'GameInfo { AddEventHandlers="CA502HChecks" }\n'}
with zipfile.ZipFile(out/'bath-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={'bath-legacy':'wait 1; netevent ca502h_bath_legacy; wait 5; quit',
 'bath-water':'wait 70; netevent ca502h_bath_water_seed; wait 5; netevent ca502h_bath_water; wait 5; quit',
 'bath-live':'wait 70; netevent ca502h_bath_live_begin; wait 90; netevent ca502h_bath_live_end; wait 5; quit',
 'bath-core':'wait 70; netevent ca502h_bath; wait 5; quit',
 'bath-save':'wait 70; netevent ca502h_bath_seed; save ca502h-bath; wait 5; quit',
 'bath-load':'wait 1; netevent ca502h_bath_load; wait 5; quit',
 'bath-hub':'wait 1; changemap CAH001; wait 70; netevent ca502h_bath_hub; changemap CAH000; wait 70; netevent ca502h_bath_hub; wait 5; quit',
 'bath-manual':'wait 70; netevent ca502h_bath_manual; bind F1 "netevent ca502h_bath_manual"; bind F2 "netevent ca_bath_open"; bind F3 "netevent ca502h_bath_status"; bind F6 toggleconsole',
 'bath-capture':'wait 70; netevent ca502h_bath_manual; netevent ca_bath_open; wait 10; screenshot bath-menu.png; netevent ca_bath_action 1; wait 35; screenshot bath-live.png; wait 5; quit'}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared independent bath addon and scripts.')
